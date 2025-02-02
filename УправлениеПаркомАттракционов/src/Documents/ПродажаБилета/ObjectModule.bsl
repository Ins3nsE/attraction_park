#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	МаксимальнаяДоля = Константы.МаксимальнаяДоляОплатыБаллами.Получить();
	
	Если Не БаллыКСписанию = 0 Тогда
		
		Если БаллыКСписанию > Цена Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Списываемые баллы не должны превышать цкену билета.";
			Сообщение.УстановитьДанные(ЭтотОбъект);
			Сообщение.Поле = "БаллыКСписанию";
			Сообщение.Сообщить();
		КонецЕсли;
		
		Если Не Цена = 0 Тогда 
			Доля = БаллыКСписанию / Цена * 100;
			
			Если Доля > МаксимальнаяДоля Тогда
				Отказ = Истина;
				Сообщение = Новый СообщениеПользователю();
				Сообщение.Текст = СтрШаблон("Доля списываемых баллов от цены больше допустимой (%1%%)", МаксимальнаяДоля);
				Сообщение.УстановитьДанные(ЭтотОбъект);
				Сообщение.Поле = "БаллыКСписанию";
				Сообщение.Сообщить();	
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;		
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ,Режим)
	
	СвойстваНоменклатуры = СвойстваНоменклатуры(Номенклатура);
	
	// регистр АктивныеПосещения
	Движения.АктивныеПосещения.Записывать = Истина;
	Движение = Движения.АктивныеПосещения.Добавить();
	Движение.Период = Дата;
	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	Движение.Основание = Ссылка;
	Движение.ВидАттракциона = СвойстваНоменклатуры.ВидАттракциона;
	Движение.КоличествоПосещений = СвойстваНоменклатуры.КоличествоПосещений;

	// регистр Продажи
	Движения.Продажи.Записывать = Истина;
	Движение = Движения.Продажи.Добавить();
	Движение.Период = Дата;
	Движение.Клиент = Клиент;
	Движение.ВидАттракциона = СвойстваНоменклатуры.ВидАттракциона;
	Движение.Сумма = СуммаДокумента;
	
	НачислитьСписатьБонусныеБаллы(Отказ);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура НачислитьСписатьБонусныеБаллы(Отказ)
	
	Движения.БонусныеБаллыКлиентов.Записывать = Истина;
	
	Если Не ЗначениеЗаполнено(Клиент) Тогда
		Возврат;
	КонецЕсли;
	
	СуммаПокупокКлиента = СуммаПокупокКлиента();
	
	ДоляНакапливаемыхБалловКлиента = ДоляНакапливаемыхБаллов(СуммаПокупокКлиента);
	
	БаллыКНакоплению = СуммаДокумента * ДоляНакапливаемыхБалловКлиента / 100;
	
	Если Не БаллыКНакоплению = 0 Тогда
		
		Движение = Движения.БонусныеБаллыКлиентов.ДобавитьПриход();
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.Сумма = БаллыКНакоплению;
		
	КонецЕсли;
			
	Если Не БаллыКСписанию = 0 Тогда
		
		Движение = Движения.БонусныеБаллыКлиентов.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.Сумма = БаллыКСписанию;		
			
	КонецЕсли;
	
	Движения.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	БонусныеБаллыКлиентовОстатки.СуммаОстаток
		|ИЗ
		|	РегистрНакопления.БонусныеБаллыКлиентов.Остатки(&Период, Клиент = &Клиент) КАК БонусныеБаллыКлиентовОстатки
		|ГДЕ
		|	БонусныеБаллыКлиентовОстатки.СуммаОстаток < 0";
		
	Запрос.УстановитьПараметр("Период", Новый Граница(МоментВремени(), ВидГраницы.Включая));
	Запрос.УстановитьПараметр("Клиент", Клиент);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = СтрШаблон("Не хватает баллов для списания, на балансе %1", 
			Выборка.СуммаОстаток + БаллыКСписанию);
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Поле = "БаллыКСписанию";
		Сообщение.Сообщить();	
	КонецЕсли;
	
КонецПроцедуры

Функция ДоляНакапливаемыхБаллов(СуммаПокупокКлиента)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ШкалаБонуснойПрограммыДиапазоны.ПроцентНакопления
		|ИЗ
		|	РегистрСведений.АктуальнаяШкалаБонуснойПрограммы.СрезПоследних(&Период,) КАК
		|		АктуальнаяШкалаБонуснойПрограммыСрезПоследних
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ШкалаБонуснойПрограммы.Диапазоны КАК ШкалаБонуснойПрограммыДиапазоны
		|		ПО АктуальнаяШкалаБонуснойПрограммыСрезПоследних.Шкала = ШкалаБонуснойПрограммыДиапазоны.Ссылка
		|ГДЕ
		|	ШкалаБонуснойПрограммыДиапазоны.НижняяГраница <= &СуммаПокупокКлиента
		|	И (ШкалаБонуснойПрограммыДиапазоны.ВерхняяГраница > &СуммаПокупокКлиента
		|	ИЛИ ШкалаБонуснойПрограммыДиапазоны.ВерхняяГраница = 0)";
		
	Запрос.УстановитьПараметр("СуммаПокупокКлиента", СуммаПокупокКлиента);
	Запрос.УстановитьПараметр("Период", Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ПроцентНакопления;
	КонецЕсли;
		
	Возврат 0;
		
КонецФункции

Функция СуммаПокупокКлиента()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПродажиОбороты.СуммаОборот
		|ИЗ
		|	РегистрНакопления.Продажи.Обороты(, &КонецПериода,, Клиент = &Клиент) КАК ПродажиОбороты";
		
	Запрос.УстановитьПараметр("КонецПериода", Новый Граница(МоментВремени(), ВидГраницы.Исключая));
	Запрос.УстановитьПараметр("Клиент", Клиент);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.СуммаОборот;
	КонецЕсли;
	
	Возврат 0;
	
КонецФункции

Функция СвойстваНоменклатуры(Номенклатура)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Номенклатура.ВидАттракциона,
	|	Номенклатура.КоличествоПосещений
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Номенклатура);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	СвойстваНоменклатуры = Новый Структура;
	СвойстваНоменклатуры.Вставить("ВидАттракциона", Выборка.ВидАттракциона);
	СвойстваНоменклатуры.Вставить("КоличествоПосещений", Выборка.КоличествоПосещений);
	
	Возврат СвойстваНоменклатуры;		
	
КонецФункции

#КонецОбласти

#КонецЕсли
