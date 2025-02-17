// @strict-types


#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Возвращает цену номенклатуры, на указанную дату.
// 
// Параметры:
//  Номенклатура - СправочникСсылка.Номенклатура - Номенклатура
//  Дата - Дата, Неопределено - Дата
// 
// Возвращаемое значение:
//  Число - Цена номенклатуры
Функция ЦенаНоменклатуры(Номенклатура, Дата = Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныНоменклатурыСрезПоследних.Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&Период, Номенклатура = &Номенклатура) КАК
		|		ЦеныНоменклатурыСрезПоследних";
		
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Период", Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Цена;
	КонецЕсли;
	
	Возврат 0;	
	
КонецФункции

#КонецОбласти

#КонецЕсли
