//+------------------------------------------------------------------+
//|
//|   プログラミング練習、テスト用
//|
//+------------------------------------------------------------------+

#property strict

class CRen{
private: 
   int AI;

public:    
   int get_price(); // メソッドの宣言
   
};

// メソッドの定義付け
int CRen::get_price(void)
{
   AI = 100 + 20;
   
   return AI;
}

int OnInit()
  {
   CRen ren; // オブジェクト生成
   
   Print( ren.get_price() );
   
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
  }