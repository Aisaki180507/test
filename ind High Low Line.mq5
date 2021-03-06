//+------------------------------------------------------------------+
//|  ●--- 任意の時間軸の高値安値を表示するインジケータ ---●
//|
//|  バッファ1 --- 高値
//|  バッファ2 --- 安値
//|  
//|  入力パラメータ --- ENUM_TIMEFRAMES TF //タイムフレーム
//|  
//+------------------------------------------------------------------+

/**/
#property copyright "Aisaki"
#property link ""
#property version "1.00"
/**/

#property indicator_chart_window          //メインウィンドウに表示
#property indicator_buffers 2             //指標バッファの数

#property indicator_plots 2               //表示させる指標バッファの数

#property indicator_type1 DRAW_LINE       //指標の種類
#property indicator_width1 1              //ラインの太さ
#property indicator_style1 STYLE_SOLID    //ラインの種類
#property indicator_color1 clrDeepSkyBlue

#property indicator_type2 DRAW_LINE       //指標の種類
#property indicator_width2 1              //ラインの太さ
#property indicator_style2 STYLE_SOLID    //ラインの種類
#property indicator_color2 clrDeepSkyBlue

input ENUM_TIMEFRAMES TF = PERIOD_D1;     //タイムフレーム

double Highest[],Lowest[];                //指標バッファ用の配列の宣言

int OnInit()
  {
   SetIndexBuffer(0, Highest);      //配列を指標バッファに関連付ける
   ArraySetAsSeries(Highest,true);
   SetIndexBuffer(1, Lowest);       //配列を指標バッファに関連付ける
   ArraySetAsSeries(Lowest,true);
  
   return(INIT_SUCCEEDED);
  }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int limit = rates_total - prev_calculated; //プロットするバーの数
   
   //最初の1回だけ指標バッファ用の配列を初期化
   if(prev_calculated == 0)
   {
      ZeroMemory(Highest);
      ZeroMemory(Lowest);
   }
   
   //チャートの時間軸が設定タイムフレームより下ならラインを表示
   if(ChartPeriod() < TF){
      for(int i=0; i<limit; i++)
      {
         //当日の最高値、最安値を更新したとき(最初の1回目は処理しない)
         if( prev_calculated != 0
            && ( Highest[0] < iHigh(_Symbol,TF,iBarShift(_Symbol,TF,iTime(_Symbol,PERIOD_CURRENT,i),false))
            || Lowest[0] > iLow(_Symbol,TF,iBarShift(_Symbol,TF,iTime(_Symbol,PERIOD_CURRENT,i),false)) ))
         {
            //当日分のみ値を更新
            int j=0;
            do{
               Highest[j] = iHigh(_Symbol,TF,iBarShift(_Symbol,TF,iTime(_Symbol,PERIOD_CURRENT,j),false));
               Lowest[j] = iLow(_Symbol,TF,iBarShift(_Symbol,TF,iTime(_Symbol,PERIOD_CURRENT,j),false));
               
               j++;
               
            }while( 0 == iBarShift(_Symbol,TF,iTime(_Symbol,PERIOD_CURRENT,j),false));         }
         else //当日の最高値、最安値を更新しないとき(最初の1回目は全必ず処理)
         {
            Highest[i] = iHigh(_Symbol,TF,iBarShift(_Symbol,TF,iTime(_Symbol,PERIOD_CURRENT,i),false));
            Lowest[i] = iLow(_Symbol,TF,iBarShift(_Symbol,TF,iTime(_Symbol,PERIOD_CURRENT,i),false));
         }
      }
   }
   
   return(rates_total-1);
  }
