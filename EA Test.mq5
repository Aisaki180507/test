//+------------------------------------------------------------------+
//|
//|   プログラミング練習、テスト用
//|
//+------------------------------------------------------------------+

#property strict

// CRenという名前のクラスを作成
class CRen{
private:
   int AI;

public:
   int get_AI() { return AI; };
   void set_AI(int ai) { AI = ai; };
};

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