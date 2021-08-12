//#property copyright ""
//#property link ""
//#property version "1.00"
#property strict

input ulong Magic = 1234;//Magic number
input double Lots = 0.1;//Lots
input ulong Slippage = 20;//Slippage
input double tp_pips = 0; //Take profit
input double sl_pips = 0; //Stop loss
input ENUM_ORDER_TYPE_FILLING OrderTypeFilling = ORDER_FILLING_IOC; //
input string EaComment = "";//Comment
input string Global_Variable_Name = "";//

input ENUM_TIMEFRAMES TF = PERIOD_M5; //実行タイムフレーム
input bool SetPosKeepHour = false;
input int PosKeepHour = 5; //Position keep the max time(hour)
input bool SetTradeTime = true; //停止時刻を設定する
input int EntryHour = 7; //エントリー許可時刻（時）
input int ExitHour = 22; //ポジション停止終了時刻（時）
input bool MonFilter = true;//月曜日フィルターON

input int ShortMAPeriod = 5;
input int LongMAPeriod = 25;

int ShortMAHandle;
double ShortMA[];
int LongMAHandle;
double LongMA[];

ulong Tiket = 0;
datetime ExTime = 0;
//int EnMethod = 1,ExMethod = 1;

int OnInit()
  {
   ShortMAHandle = iMA(_Symbol,TF,ShortMAPeriod,0,MODE_SMA,PRICE_CLOSE);
   ArraySetAsSeries(ShortMA,true);
   
   LongMAHandle = iMA(_Symbol,TF,LongMAPeriod,0,MODE_SMA,PRICE_CLOSE);
   ArraySetAsSeries(LongMA,true);

   return(INIT_SUCCEEDED);
  }

/**
void OnDeinit(const int reason)
  {
   
  }
//*/

void OnTick()
  {
   ENUM_ORDER_TYPE OrderType = 0;
   int AllExit = 0;
   
   double tp_price = 0;
   double sl_price = 0;
   
   MqlTradeRequest Request;
   MqlTradeResult Result;
   
   //get entry signal , send entry order
   if(EntrySignal(OrderType) == 1 && Tiket == 0 && (ExTime + PeriodSeconds(TF) ) < TimeCurrent() )
   {
      ZeroMemory(Request);
      ZeroMemory(Result);

      Request.action = TRADE_ACTION_DEAL;
      Request.magic = Magic;
      Request.symbol = _Symbol;
      Request.volume = Lots;
      if(OrderType == ORDER_TYPE_BUY)
      {
         Request.type = ORDER_TYPE_BUY;
         Request.price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         if(tp_pips > 0) tp_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK)+MyPipsToPrice(tp_pips);
         if(sl_pips > 0) sl_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK)-MyPipsToPrice(sl_pips);
      }
      if(OrderType == ORDER_TYPE_SELL)
      {
         Request.type = ORDER_TYPE_SELL;
         Request.price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         if(tp_pips > 0) tp_price = SymbolInfoDouble(_Symbol,SYMBOL_BID)+MyPipsToPrice(tp_pips);
         if(sl_pips > 0) sl_price = SymbolInfoDouble(_Symbol,SYMBOL_BID)-MyPipsToPrice(sl_pips);
      }
      Request.sl = sl_price;
      Request.tp = tp_price;
      Request.deviation = Slippage;
      Request.comment = EaComment;
      Request.type_filling = OrderTypeFilling;
      
      OrderSend(Request,Result);
      PrintFormat("OrderSend %d",Result.retcode);//GetLastError()
      
      Tiket = Result.deal;
   }
   
   //get exit signal , send exit order
   if( ExitSignal(OrderType, AllExit) == 1 && PositionSelectByTicket(Tiket))
   {
      ZeroMemory(Request);
      ZeroMemory(Result);

      Request.position = Tiket;
      Request.action = TRADE_ACTION_DEAL;
      Request.magic = Magic;
      Request.symbol = _Symbol;
      Request.volume = Lots;
      Request.deviation = Slippage;
      Request.comment = EaComment;
      if( PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && (AllExit == 1 || OrderType == ORDER_TYPE_SELL) )
      {
         Request.price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         Request.type = ORDER_TYPE_SELL;
      }
      if( PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && (AllExit == 1 || OrderType == ORDER_TYPE_BUY) )
      {
         Request.price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         Request.type = ORDER_TYPE_BUY;
      }
      Request.type_filling = OrderTypeFilling;
      
      if(OrderSend(Request,Result) )
      {
         Tiket = 0;
         ExTime = TimeCurrent();
      }
      PrintFormat("OrderSend error %d",GetLastError());
   }

  }


//+------------------------------------------------------------------+
//| Signal Code                                                      |
//+------------------------------------------------------------------+


int EntrySignal(ENUM_ORDER_TYPE &order_type)
{
   int EnSignal = 0;
   order_type = 0;
   
   //double Close[];

   //CopyBuffer(handle,0,0,2,);
   //CopyClose(_Symbol,PERIOD_CURRENT,0,3,Close);


   /**/
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   
   if(SetTradeTime)
   {
      if( EntryHour < ExitHour && (dt.hour >= EntryHour && dt.hour < ExitHour) ) EnSignal = EnSignal;
      else if (EntryHour > ExitHour && (dt.hour >= EntryHour || dt.hour < ExitHour) ) EnSignal = EnSignal;
      else EnSignal = 0;
   }
   //*/
   
   if(GlobalVariableCheck(Global_Variable_Name))
   {
      if(GlobalVariableGet(Global_Variable_Name) == 1) EnSignal = 0;
   }


   return EnSignal;   
}

int ExitSignal(ENUM_ORDER_TYPE &order_type, int &all_exit)
{
   int ExSignal = 0;
   order_type = 0;
   all_exit = 0;

   //double Close[];
   
   //CopyBuffer(handle,0,0,2,);
   //CopyClose(_Symbol,PERIOD_CURRENT,0,3,Close);
   
   
   
   if(FilterSignal() == 0 )
   {
      ExSignal = 1;
      all_exit = 1;
   }
   
   /**/
   if(SetPosKeepHour && PositionSelectByTicket(Tiket))//
   {
      if( (TimeCurrent() - PositionGetInteger(POSITION_TIME)) >= PosKeepHour*60*60 )//
      {
         ExSignal = 1;
         all_exit = 1;
      }
   }
   //*/
   
   /**/
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   
   
   if(SetTradeTime && dt.hour == ExitHour) 
   {
      ExSignal = 1;
      all_exit = 1;
   }
   //*/

   return ExSignal;
}

int FilterSignal()
{
  int FilSignal = 0;
  
  return FilSignal;
}

//pipsから価格へ
double MyPipsToPrice(double pips)
{
   double ret_price = 0;
   
   if(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) == 3 || SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) == 2 ) ret_price = pips/100;
   if(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) == 4 || SymbolInfoInteger(_Symbol,SYMBOL_DIGITS) == 5 ) ret_price = pips/10000;
   
   return ret_price;
}
