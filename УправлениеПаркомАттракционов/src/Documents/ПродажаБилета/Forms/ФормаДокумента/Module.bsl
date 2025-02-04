#Область ОбработчикиСобытийФормы

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СкидкаПриИзменении(Элемент)
	РассчитатьСуммуДокумента();	
КонецПроцедуры

&НаКлиенте
Процедура СуммаДокументаПриИзменении(Элемент)
	Объект.БаллыКСписанию = Объект.ПозицииПродажи.Итог("Сумма") - Объект.СуммаДокумента;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПозицииПродажи

&НаКлиенте
Процедура ПозицииПродажиНоменклатураПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.ПозицииПродажи.ТекущиеДанные;
	
	ТекущиеДанные.Цена = ЦенаНоменклатуры(ТекущиеДанные.Номенклатура, Объект.Дата);
	
	РассчитатьСуммуСтроки(ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ПозицииПродажиЦенаПриИзменении(Элемент)

	ТекущиеДанные = Элементы.ПозицииПродажи.ТекущиеДанные;
	
	РассчитатьСуммуСтроки(ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ПозицииПродажиКоличествоПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.ПозицииПродажи.ТекущиеДанные;
	
	РассчитатьСуммуСтроки(ТекущиеДанные);
		
КонецПроцедуры

&НаКлиенте
Процедура ПозицииПродажиПриИзменении(Элемент)
	РассчитатьСуммуДокумента();	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура РассчитатьСуммуДокумента()
	
	Объект.СуммаДокумента = Объект.ПозицииПродажи.Итог("Сумма") - Объект.БаллыКСписанию;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЦенаНоменклатуры(Знач Номенклатура, Знач Период)
	
	Возврат РегистрыСведений.ЦеныНоменклатуры.ЦенаНоменклатуры(Номенклатура, Период);	
	
КонецФункции

&НаКлиенте
Процедура РассчитатьСуммуСтроки(ДанныеСтроки)
	
	ДанныеСтроки.Сумма = ДанныеСтроки.Цена * ДанныеСтроки.Количество;		
	
КонецПроцедуры

#КонецОбласти
