//+------------------------------------------------------------------+
//|
//|   プログラミング練習、テスト用
//|
//+------------------------------------------------------------------+

#property strict

// 基底クラス
class CRen{
private: 
   int   AI;

public: 
   int get_AI() { return AI; };
   void set_AI(int ai) { AI = ai; };
   
};

// 派生クラス
class CPractice :public CRen{
private:
   int   SA;

public:
   int get_SA() { return SA; };
   void set_SA(int sa) { SA = sa*2; };
};

int OnInit()
  {
   CPractice ren; // オブジェクト生成
   
   // 派生クラスのメソッドを使う
   ren.set_SA( 1234 );
   Print("派生クラスのメソッド ", ren.get_SA() );
   
   // 基底クラスのメソッドを使う
   ren.set_AI( 1234 );
   Print("基底クラスのメソッド ", ren.get_AI() );
   
   
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
  }