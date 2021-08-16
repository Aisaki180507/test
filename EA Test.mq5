//+------------------------------------------------------------------+
//|
//|   プログラミング練習、テスト用
//|
//+------------------------------------------------------------------+

#property strict

class CRen{
private: 
   int    AI;
   double SA;

public: 
   int get_AI() { return AI; };
   void set_AI(int ai) { AI = ai; };
   
   CRen();   // コンストラクタ
   ~CRen();  // デストラクタ
};

CRen::CRen(void)
{
   SA = iClose(_Symbol,PERIOD_CURRENT,0);
   Print("コンストラクタ 現在の価格は ",SA);
}

CRen::~CRen(void)
{
   Print("デストラクタ SAの値は ",SA," AIの値は ",AI);
}


int OnInit()
  {
   CRen ren; // オブジェクト生成
   
   ren.set_AI( 1234 );
   Print( ren.get_AI() );
   
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
  }