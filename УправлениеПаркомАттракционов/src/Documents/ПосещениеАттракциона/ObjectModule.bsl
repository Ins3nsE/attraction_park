// @strict-types

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ,Режим)
	
	Движения.АктивныеПосещения.Записывать = Истина;
	Движения.Записать();
	
	Выборка = АктивныеПосещения();
	
	ОсталосьПосещений = 0;
	ВидАттракционаАбонемента = Неопределено;
	Если Выборка.Следующий() Тогда
		ОсталосьПосещений = Выборка.КоличествоПосещенийОстаток;
		ВидАттракционаАбонемента = Выборка.ВидАттракциона;
	КонецЕсли;
	
	Если ОсталосьПосещений < 1 Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "В билете не осталось посещений.";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Поле = "Основание";
		Сообщение.Сообщить();
	КонецЕсли;
	
	ВидАттракционаДокумента = ВидАттракциона(Аттракцион);
	Если ЗначениеЗаполнено(ВидАттракционаАбонемента)
		И ВидАттракционаДокумента <> ВидАттракционаАбонемента Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Билет не подходит для посещения этого аттракциона.";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Поле = "Основание";
		Сообщение.Сообщить();
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// регистр АктивныеПосещения
	Движения.АктивныеПосещения.Записывать = Истина;
	Движение = Движения.АктивныеПосещения.Добавить();
	Движение.Период = Дата;
	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
	Движение.Основание = Основание;
	Движение.ВидАттракциона = ВидАттракционаАбонемента;
	Движение.КоличествоПосещений = 1;
	
	// Регистр Посещения аттракционов
	Движения.ПосещенияАттракционов.Записывать = Истина;
	ДвижениеПосещениеАттракционов = Движения.ПосещенияАттракционов.Добавить();
	ДвижениеПосещениеАттракционов.Период = Дата;
	ДвижениеПосещениеАттракционов.Аттракцион = Аттракцион;
	ДвижениеПосещениеАттракционов.Клиент = КлиентПоОснованию();
	ДвижениеПосещениеАттракционов.Количество = 1;
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Ответственный = Пользователи.ТекущийПользователь();
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	Ответственный = Пользователи.ТекущийПользователь();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Активные посещения.
// 
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса - Активные посещения:
//	 * ВидАттракциона - СправочникСсылка.ВидыАттракционов
//	 * КоличествоПосещенийОстаток - Число
Функция АктивныеПосещения()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	АктивныеПосещенияОстатки.ВидАттракциона,
		|	АктивныеПосещенияОстатки.КоличествоПосещенийОстаток
		|ИЗ
		|	РегистрНакопления.АктивныеПосещения.Остатки(, Основание = &Основание) КАК АктивныеПосещенияОстатки";
	
	Запрос.УстановитьПараметр("Основание", Основание);
	Выборка = Запрос.Выполнить().Выбрать();
	Возврат Выборка;
	
КонецФункции

// Вид аттракциона.
// 
// Параметры:
//  Аттракцион - СправочникСсылка.Аттракционы - Аттракцион
// 
// Возвращаемое значение:
//  СправочникСсылка.ВидыАттракционов 
Функция ВидАттракциона(Аттракцион)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Аттракционы.ВидАттракциона
	|ИЗ
	|	Справочник.Аттракционы КАК Аттракционы
	|ГДЕ
	|	Аттракционы.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Аттракцион);
	
	Выборка = Запрос.Выполнить().Выбрать(); 
	Выборка.Следующий();
	
	Возврат Выборка.ВидАттракциона;		
	
КонецФункции

Функция КлиентПоОснованию()
		
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ПродажаБилета.Клиент
		|ИЗ
		|	Документ.ПродажаБилета КАК ПродажаБилета
		|ГДЕ
		|	ПродажаБилета.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Выборка.Следующий();
	
	Возврат Выборка.Клиент;
	
КонецФункции

#КонецОбласти

#КонецЕсли
