//+------------------------------------------------------------------+
//|
//|   プログラミング練習、テスト用
//|
//+------------------------------------------------------------------+

#property strict

// StrRenという名前の構造体を作成
struct StrRen{
   int    ren_a;
   double ren_b;
   string ren_c;
};

int OnInit()
  {
   StrRen ren; // オブジェクト生成
   
   ren.ren_a = 10;
   ren.ren_b = 2.1;
   ren.ren_c = "abc";
   
   Print(ren.ren_a);
   Print(ren.ren_b);
   Print(ren.ren_c);
   
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
  }
/**
   ren.ren_b = iClose(_Symbol,PERIOD_CURRENT,0);
   
   Print(ren.ren_a);
   Print(ren.ren_b);
   Print(ren.ren_c);
   
/**/