//+------------------------------------------------------------------+
//|                                                    AutoMoney.mq5 |
//|                                                            Denis |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Denis"
#property link      ""
#property version   "1.00"
// Файлы проверки ошибок с MQL5
///#include <CheckMoneyForTrade.mqh> // Нехватка средств для проведения торговой операции
//#include <CheckVolumeValue.mqh>   // Неправильные объемы в торговых операциях
//#include <IsNewOrderAllowed.mqh>  // Ограничение на количество отложенных ордеров
// Ограничение на количество лотов по одному символу - внедрить
// Установка уровней TakeProfit и StopLoss в пределах минимального уровня SYMBOL_TRADE_STOPS_LEVEL - внедрить
// Попытка модификации ордера или позиции в пределах уровня заморозки SYMBOL_TRADE_FREEZE_LEVEL - внедрить
// Ошибки, возникающие при работе с символами с недостаточной историей котировок
// Выход за пределы мссива (array out of range)
// Отправка запроса на модификацию уровней без фактического их изменения
// Попытка импорта скомпилированных файлов (даже EX4/EX5) и DLL
// Обращение к пользовательским индикаторам через iCustom()
// Передача недопустимого параметра в функцию (ошибки времени выполнения)
// Access violation
// Потребление ресурсов процессора памяти

// Мои файлы
//#include <Errors.mqh>
//#include <ErrorsServer.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <tim.mqh>
//переменные времени
string RealTimeServer;
string RealTimeYear;
string RealTimeMonth;
string Hor;
string Minut;
bool time;
int TimePeriod = 0;

enum PERIOD {PERIOD_M5};      // общий таймфрейм программы
input double OP_EURUSD = 100; // ПРОБИТИЕ
input double SL_EURUSD = 100; // ЗАЩИТА
input double TS_EURUSD = 100; // ФИКСАЦИЯ
double lot = 0.01;
double bid;
double ask;
double spread;
bool prices = false;
ENUM_ORDER_TYPE type_Buy = ORDER_TYPE_BUY_STOP;
ENUM_ORDER_TYPE type_Sell = ORDER_TYPE_SELL_STOP;
double balance;
double RealFreeBalance;
double balances;                // общий баланс счета
double balanceFreeMargin;       // свободная маржа
int CreditPlecho;               // кредитное плече счета
double res_Buy;
double res_Sell;
//+------------------------------------------------------------------+
//| Expert start function                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//+------------------------------------------------------------------+
//| Balance.mqh                                                      | // рассчитать баланс при открытии сделок с учетом плеча
//+------------------------------------------------------------------+ // информация по счету от брокера
  /* Print("Валюта счета: ",AccountInfoString(ACCOUNT_CURRENCY));
   Print("Баланс счета: ",AccountInfoDouble(ACCOUNT_BALANCE));
   Print("Кредитное плечо: ",AccountInfoInteger(ACCOUNT_LEVERAGE));
   Print("Максимальное количество отложенных ордеров ",ACCOUNT_LIMIT_ORDERS);
   
   Print("Размер предоставленного кредита: ",AccountInfoDouble(ACCOUNT_CREDIT));
   Print("Размер текущей прибыли: ",AccountInfoDouble(ACCOUNT_PROFIT));
   Print("Значение собственных средств: ",AccountInfoDouble(ACCOUNT_EQUITY));
   Print("Размер свободных средств на счете: ",AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   Print("Размер зарезервированных залоговых средств: ",AccountInfoDouble(ACCOUNT_MARGIN));
   Print("Уровень залоговых средств на счете в процентах: ",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   Print("Уровень залоговых средств, при котором требуется пополнение счета: ",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   Print("Уровень залоговых средств, при достижении которого происходит принудительное закрытие самой убыточной позиции (Stop Out): ",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
   Print("Размер средств, зарезервированных на счёте, для обеспечения гарантийной суммы по всем отложенным ордерам: ",AccountInfoDouble(ACCOUNT_MARGIN_INITIAL));
   Print("Размер средств, зарезервированных на счёте, для обеспечения минимальной суммы по всем открытым позициям: ",AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE));
   Print("Текущий размер активов на счёте: ",AccountInfoDouble(ACCOUNT_ASSETS));
   Print("Текущий размер обязательств на счёте: ",AccountInfoDouble(ACCOUNT_LIABILITIES));
   Print("Текущая сумма заблокированных комиссий по счёту: ",AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED));
   
   Print("--------------------");
   */
   /*
      просчитать маржу независимо от валютной пары
      нужна цена доллара максимум или последняя известная
      ASK текущего символа * 1000 / кредитное плече
      результат умноженный в рубли = предполагаемый заг на 0,01 лота
      ---
      количество отложенных ордеров < 47
      ---
      свободные средства > предполагаемого залога
   */
   
   //double RealPrice = iHigh(Symbol(),PERIOD_M1,0); // текущая цена рубль//доллар
   //double RealZalog = NormalizeDouble(RealPrice*1000/AccountInfoInteger(ACCOUNT_LEVERAGE),2); // AccountInfoInteger(ACCOUNT_LEVERAGE)
 // текущий залог в рублях, нормализованный
   //Print("Маржа = ",RealZalogRub);
//SendNotification("Эксперт инициализирован"); // PUSH уведомление на телефон

//+------------------------------------------------------------------+
//| Balance.mqh                                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Price.mqh                                                        |
//+------------------------------------------------------------------+
   MqlTick price;
   if(SymbolInfoTick(Symbol(),price)==true)
     {
      bid = price.bid;
      ask = price.ask;
      spread = NormalizeDouble(ask-bid,Digits());
     }
   else
     {
      prices = false;
     }
//+------------------------------------------------------------------+
//| Price.mqh                                                        |
//+------------------------------------------------------------------+
   Sleep(3000);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//+------------------------------------------------------------------+
//| Возможность открытия новых ордеров
//+------------------------------------------------------------------+  
//+------------------------------------------------------------------+
//| Возможность открытия новых ордеров
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Рассчет лота (все валюты * на маржу <> баланс = лот)
//+------------------------------------------------------------------+  
   //lot = NormalizeDouble(RealFreeBalance/250000,2);
//+------------------------------------------------------------------+
//| Рассчет лота (все валюты * на маржу <> баланс = лот)
//+------------------------------------------------------------------+  
//+------------------------------------------------------------------+
//| Price.mqh присваиваем текущие bid и ask цены переменным          |
//+------------------------------------------------------------------+
   MqlTick price;
   if(SymbolInfoTick(Symbol(),price)==true)
     {
      bid = price.bid;
      ask = price.ask;
      prices = true;
      spread = NormalizeDouble(ask-bid,Digits());
     }
   else
     {
      prices = false;
     }
//+------------------------------------------------------------------+
//| Price.mqh                                                        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OrderModifyActive.mqh модифицируем действующие ордера            |
//+------------------------------------------------------------------+
   MqlTradeRequest request1;
   MqlTradeResult result1;
   int total1=PositionsTotal();                                                     // получаем количество активных ордеров
   for(int i=0; i<total1; i++)
     {
      ulong position_ticket = PositionGetTicket(i);                                 // тикет позиции
      double sl=PositionGetDouble(POSITION_SL);                                     // Stop Loss позиции текущий
      string coment = PositionGetString(POSITION_COMMENT);
      double price1 = PositionGetDouble(POSITION_PRICE_OPEN);                       // цена открытия ордера
      double stl_Buy  = NormalizeDouble(bid-TS_EURUSD*Point(),Digits());            // цена нового стоп лосса
      double stl_Sell = NormalizeDouble(ask+TS_EURUSD*Point(),Digits());
      //***********************************************************************
      if((coment == (Symbol() + "_Time_BUY"))   &&                                  // тип ордера SELL или BAY
         (bid > price1+spread)                  &&
         (stl_Buy != sl)                        &&                                  // новый стоп лосс не равен старому стоп лоссу
         (stl_Buy > sl)                         &&                                  // новый стоп лосс больше старого стоп лосса
         (prices == true))
         {
            ZeroMemory(request1);                                                   // обнуление структуры по всей видимости
            ZeroMemory(result1);
            request1.action = TRADE_ACTION_SLTP;                                    // выбор типа торговой операции
            request1.position = position_ticket;                                    // тикет текущей позиции в цикле
            request1.sl = stl_Buy;                                                  // новый стоп лосс
            if(!OrderSend(request1,result1))                                        // если одер не открылся
               PrintFormat("Ошибка модификации BUY %d", GetLastError());            // обрабатываем ошибку
         }
      if((coment == (Symbol() + "_Time_SELL"))  &&
         (ask < price1-spread)                  &&
         (stl_Sell != sl)                       &&
         (stl_Sell < sl)                        &&
         (prices == true))
         {
            ZeroMemory(request1); 
            ZeroMemory(result1);
            request1.action = TRADE_ACTION_SLTP; 
            request1.position = position_ticket; 
            request1.sl = stl_Sell;       
            if(!OrderSend(request1,result1))                                 
               PrintFormat("Ошибка модификации SELL %d", GetLastError());   
         }
     }
//+------------------------------------------------------------------+
//| OrderModifyActive.mqh                                            |
//+------------------------------------------------------------------+
// инициализируем переменные времени сервера
   RealTimeServer = TimeToString(TimeCurrent());
   RealTimeYear   = RealTimeServer.Substr(0,4);
   RealTimeMonth  = RealTimeServer.Substr(5,2);
   Hor    = RealTimeServer.Substr(11,2);
   Minut  = RealTimeServer.Substr(14,2);
// инициализируем переменные времени сервера
   if((RealTimeMonth == "11") || (RealTimeMonth == "12") || (RealTimeMonth == "01") || (RealTimeMonth == "03") || (RealTimeMonth == "03")){
      TimePeriod = 1; // зимнее время (ноябрь, декабрь, январь, февраль, март)
   }
   else{
      TimePeriod = 2; // летнее время (апрель, май, июнь, июль, август, сентябрь, октябрь)
   }
   
   // удаляем неактивировавшиеся отложенные ордера
   if((Minut == "06") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "11") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "16") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "21") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "26") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "31") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "36") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "41") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "46") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "51") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "56") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   if((Minut == "01") && (time == false))
      {
         OrdersModifyPerspective();
         time = true;
      }
   
   switch(TimePeriod) {
   case 1: // ЗИМА на час позже  - USD 16:30
      tim();
   case 2: // ЛЕТО на час раньше - USD 15:30
      tim();
   }
//+------------------------------------------------------------------+
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool OpenOrder(ENUM_ORDER_TYPE type1, double PricesMAX,double PricesMIN, double OP_Symbol, double SL_Symbol, string Comm, string DopComm, int pips)
  {
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   request.action = TRADE_ACTION_PENDING;
   request.symbol = Comm;
   request.volume = lot;

   if(type1 == ORDER_TYPE_BUY_STOP)
     {
      request.type = type1;
      request.price = NormalizeDouble(PricesMAX+OP_Symbol*Point(),pips);
      request.sl = NormalizeDouble(PricesMIN-SL_Symbol*Point(),pips);
      request.comment = Comm + DopComm;
      if(!OrderSend(request,result))
        {PrintFormat(Comm+DopComm, " - Error open order - %d", GetLastError());}
      else
        {
         Print("Ticket order ",Comm+DopComm," ", result.order);
        }
     }
   if(type1 == ORDER_TYPE_SELL_STOP)
     {
      request.type = type1;
      request.price = NormalizeDouble(PricesMIN-OP_Symbol*Point(),pips);
      request.sl = NormalizeDouble(PricesMAX+SL_Symbol*Point(),pips);
      request.comment = Comm + DopComm;
      if(!OrderSend(request,result))
        {PrintFormat(Comm+DopComm, " - Error open order - %d", GetLastError());}
      else
        {
         Print("Ticket order ",Comm+DopComm," ", result.order);
        }
     }
     time = false;
   return(true);
  }
//+------------------------------------------------------------------+
void OrdersModifyPerspective()
{
   MqlTradeRequest request2 = {};
   MqlTradeResult result2 = {};
   int total2=OrdersTotal();
   for(int i=total2-1;i>=0;i--)
   {
      ulong  order_ticket=OrderGetTicket(i);                   // тикет ордера
      ZeroMemory(request2);
      ZeroMemory(result2);
      request2.action=TRADE_ACTION_REMOVE;                     // тип торговой операции
      request2.order = order_ticket;                           // тикет ордера
      if(!OrderSend(request2,result2))
         PrintFormat("OrderSend error %d",GetLastError());
   }
};