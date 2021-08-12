//+------------------------------------------------------------------+
//|  ●---バックテスト専用---●
//|
//|  ランダムに注文を出すEAです
//|  他のEAとの比較、検証のために作っています
//|  実運用しないように注意してください
//+------------------------------------------------------------------+

/**/
#property copyright "Aisaki"
#property link ""
#property version "1.00"
/**/

#include <Trade\Trade.mqh>

CTrade ExtTrade;

#property strict

input group    "●--EAの基本設定--●"
sinput ENUM_LOG_LEVELS loglevel = LOG_LEVEL_ERRORS; // メッセージログの表示/非表示を設定
enum ENUM_ORDER_MODE{
   Buy_and_Sell = 0, //買いと売り、両注文を許可
   Buy_only     = 1, //買い注文のみを許可
   Sell_only    = 2  //売り注文のみを許可
};
sinput ENUM_ORDER_MODE Order_Mode = 0;              // 注文の制限
sinput ulong           Magic = 9999;                // マジックナンバー
input ulong            EN_Slippage = 20;            // 新規注文の許容スリッページ
input ulong            EX_Slippage = 1000;          // 決済注文の許容スリッページ
input uint             Spread = 1000;               // 許容スプレッド
enum ENUM_FILLING_MODE{
   auto           = 1,  //自動
   FILLING_FOK    = 2,  //ORDER_FILLING_FOK
   FILLING_IOC    = 3,  //ORDER_FILLING_IOC
   FILLING_RETURN = 4,  //ORDER_FILLING_RETURN
   Not_set        = 0   //設定しない
};
input ENUM_FILLING_MODE OrderTypeFillingMode = 0;  // 注文充填の種類
input string            EaComment = "";            // 注文に付加するコメント

input group    "●--ポジションサイジング--●"
enum ENUM_POSITIONSIZING{
   PositionSizing0 = 0, //固定ロットモード
   PositionSizing1 = 1  //固定比率モード
};
sinput ENUM_POSITIONSIZING PSMode = 0;             // ポジションサイジングモード
sinput double              InputLots = 0.1;        // ロット数 (固定ロットモード)
input double               amount = 750000;        // 〇〇円毎に1ロット (固定比率モード)
sinput double              MarginRatio = 0.2;      // このEAが残高の何％を運用するか (固定比率モード)

input group    "●--仕掛けロジックパラメータ--●"
input ENUM_TIMEFRAMES   TF = PERIOD_M1;            // 実行タイムフレーム
input long              FreEN = 60;                // ローソク足確定時に1/○でエントリー
input double            BuyRatio = 0.5;            // 買い注文をする確率

input group    "●--手仕舞いロジックパラメータ--●"
input long              FreEX = 60;                // ローソク足確定時に1/○で決済

double Lots = InputLots;
datetime OpenTime = 0;

int OnInit()
  {
   // EAの初期設定
   ExtTrade.LogLevel(loglevel);
   ExtTrade.SetExpertMagicNumber(Magic);
   ExtTrade.SetDeviationInPoints(EN_Slippage);
   if(OrderTypeFillingMode != 0) ExtTrade.SetTypeFilling(Set_Order_Type_Filling() );
   
   return(INIT_SUCCEEDED);
  }

/**
void OnDeinit(const int reason)
  {
   
  }
/**/

void OnTick()
  {
   ulong           Tiket      = 0;
   ENUM_ORDER_TYPE OrderType  = 0;
   double          price      = 0;
   int             signal     = 0;
      
   //EAがポジションを持っているかチェック
   for(int i=0; i<PositionsTotal(); i++){
      Tiket = PositionGetTicket(i);
      if(PositionGetInteger(POSITION_MAGIC) == Magic) break;
      else Tiket = 0;
   }
   
   //エントリーシグナルを受け取る
   if( Tiket == 0 ) signal = EntrySignal();
   
   if( signal == 1 ){
      OrderType = ORDER_TYPE_BUY;
      price     = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      if( Order_Mode == 2 ) signal = 0;
   }
   else if( signal == -1 ){
      OrderType = ORDER_TYPE_SELL;
      price     = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      if( Order_Mode == 1 ) signal = 0;
   }
   
   //新規注文を出す
   if(  signal != 0 && Tiket == 0 &&
        SymbolInfoInteger(_Symbol,SYMBOL_SPREAD) <= Spread ){
      
      // ポジションサイジング(固定比率モード)
      if( PSMode == 1 ) Lots = Position_Sizing();

      if(!ExtTrade.PositionOpen(_Symbol,OrderType,Lots,price,0,0,EaComment) ){
      
         PrintFormat("ResultRetcode %d",ExtTrade.ResultRetcode() );
         PrintFormat("ResultDeal %d",ExtTrade.ResultDeal() );
      }
   }
   
   //イグジットシグナルを受け取る
   signal = 0;
   if( Tiket != 0 ) signal = ExitSignal(Tiket);
   
   //決済注文を出す
   if( signal != 0 && Tiket != 0 ){
   
      if(!ExtTrade.PositionClose(_Symbol,EX_Slippage) ){
         
         PrintFormat("ResultRetcode %d",ExtTrade.ResultRetcode() );      
      }
   }
   
   OpenTime = iTime(_Symbol,TF,0);
  }


//+------------------------------------------------------------------+
//| Entry Signal                                                     |
//+------------------------------------------------------------------+


int EntrySignal()
{
   int EnSignal = 0;
   
   if( OpenTime < iTime(_Symbol,TF,0) && 1 == rand() % FreEN ){
      if( 100 * BuyRatio >= rand() % 100 ){
         //Print("買いシグナル");
         EnSignal = 1;
      }
      else {
         //Print("売りシグナル");
         EnSignal = -1;
      }
   }

   return EnSignal;   
}

//+------------------------------------------------------------------+
//| Exit Signal                                                      |
//+------------------------------------------------------------------+

int ExitSignal(ulong positon_ticket)
{
   // ポジションの確認
   if(positon_ticket == 0) return 0;
   PositionSelectByTicket(positon_ticket);
   if(PositionGetInteger(POSITION_MAGIC) != Magic) return 0;
   
   int ExSignal = 0;
   
   if( OpenTime < iTime(_Symbol,TF,0) && 1 == rand() % FreEX ) ExSignal = 1;

   return ExSignal;
}

//+------------------------------------------------------------------+
//| Filter Signal                                                    |
//+------------------------------------------------------------------+
/**
int FilterSignal()
{
  int FilSignal = 0;
  
  return FilSignal;
}
/**/
//+------------------------------------------------------------------+


/* ORDER_TYPE_FILLING の設定 */
ENUM_ORDER_TYPE_FILLING Set_Order_Type_Filling()
{
   //自動選択モード
   if(OrderTypeFillingMode == 1 && SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE) == 1)      return ORDER_FILLING_FOK;
   else if(OrderTypeFillingMode == 1 && SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE) == 2) return ORDER_FILLING_IOC;
   else if(OrderTypeFillingMode == 1)                                                        return ORDER_FILLING_RETURN;
   
   //手動選択モード
   else if(OrderTypeFillingMode == 2) return ORDER_FILLING_FOK;
   else if(OrderTypeFillingMode == 3) return ORDER_FILLING_IOC;
   else if(OrderTypeFillingMode == 4) return ORDER_FILLING_RETURN;
   
   return 0;
}

// ポジションサイジング(固定比率モード)
double Position_Sizing()
{
   double step_dig = 0;
   double lot_size = 0;
   
   lot_size = AccountInfoDouble(ACCOUNT_BALANCE) * MarginRatio / amount;
   
   // 端数切捨て
   for(int i=0; i< 10;i++){
      if( (i == 0 && 1 == SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP))
            || 1 == SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP) * pow(10,i) ){
         step_dig = i;
         break;
      }
   }
   lot_size = MathFloor( lot_size * pow(10,step_dig) ) / pow(10,step_dig);
   
   // 最小ロット数以下になったらトレードしない
   if( lot_size < SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN) ) return 0;
   
   return lot_size;
}

//+------------------------------------------------------------------+
//| OnTester                                                         |
//+------------------------------------------------------------------+
input group    "●--カスタム指標--●"
enum ENUM_CUSTOM_INDEX{
   PRR           = 0, // 悲観的リターンレシオ
   PRR100        = 1, // 悲観的リターンレシオ*100
   T_Expect      = 2, // タープの期待値
   T_Expect100   = 3, // タープの期待値*100
   My_Index      = 4, // オリジナル指標
   Stand_Dev     = 5  // 損益の標準偏差
};
sinput ENUM_CUSTOM_INDEX CustomIndex = 1; //OnTesterで評価する項目

double OnTester()
{ 
   double PT = 0, LT = 0;
   
   switch (CustomIndex){
      case 0:
         PT = TesterStatistics(STAT_PROFIT_TRADES);
         LT = TesterStatistics(STAT_LOSS_TRADES);
         
         PT = ((PT - sqrt(PT)) * (TesterStatistics(STAT_GROSS_PROFIT)/PT)) /
                   ((LT + sqrt(LT)) * (-TesterStatistics(STAT_GROSS_LOSS)/LT));
         break;
      
      case 1:
         PT = TesterStatistics(STAT_PROFIT_TRADES);
         LT = TesterStatistics(STAT_LOSS_TRADES);
         
         PT = ((PT - sqrt(PT)) * (TesterStatistics(STAT_GROSS_PROFIT)/PT)) /
                   ((LT + sqrt(LT)) * (-TesterStatistics(STAT_GROSS_LOSS)/LT)) *100;//←(*100)は小数点以下を表示しないバグ対策の桁上げ
         break;
      
      case 2:
         PT = TesterStatistics(STAT_EXPECTED_PAYOFF) / (-TesterStatistics(STAT_GROSS_LOSS) / TesterStatistics(STAT_LOSS_TRADES));
         break;
      
      case 3:
         PT = TesterStatistics(STAT_EXPECTED_PAYOFF) / (-TesterStatistics(STAT_GROSS_LOSS) / TesterStatistics(STAT_LOSS_TRADES))*100;
         break;
      
      case 4:
         PT = TesterStatistics(STAT_EXPECTED_PAYOFF) / (-TesterStatistics(STAT_GROSS_LOSS) / TesterStatistics(STAT_LOSS_TRADES)) * TesterStatistics(STAT_TRADES);
         break;
      
      case 5:
         PT = TesterStatistics(STAT_EXPECTED_PAYOFF) / TesterStatistics(STAT_SHARPE_RATIO) ;
         break;
   }
   
   return PT;
}
