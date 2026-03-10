**FREE

//=====================================================================
// プログラム: IPH110NEW
// 説明: 得意先照会（サービス化版）
// 作成者: IBM i 開発チーム
// 作成日: 2026-02-24
// 備考: TOKMSSVCサービスプログラムを使用して得意先マスタにアクセス
//=====================================================================

// ファイル宣言
DCL-F IPH110S WORKSTN INDDS(Indicators);
DCL-F TOKMSP DISK(*EXT) KEYED USAGE(*INPUT);

// 標識データ構造
DCL-DS Indicators;
  Exit IND POS(3);
  NotFound IND POS(30);
END-DS;

//=====================================================================
// TOKMSSVCサービスプログラムの外部プロシージャ
// 重要: BNDDIRまたはCRTPGMのBNDSRVPGMでTOKMSSVCをバインドする必要あり
//=====================================================================

// GetCustomer - 得意先情報取得
DCL-PR GETCUSTOMER IND;
  customerNo CHAR(5) CONST;
  customerName CHAR(20);
  address1 CHAR(20);
  address2 CHAR(20);
  creditLimit PACKED(9:0);
  balance PACKED(9:0);
END-PR;

// CalcAvailable - 利用可能額計算
DCL-PR CALCAVAILABLE PACKED(9:0);
  customerNo CHAR(5) CONST;
END-PR;

//=====================================================================
// 作業変数
//=====================================================================
DCL-S custNo CHAR(5);
DCL-S custName CHAR(20);
DCL-S addr1 CHAR(20);
DCL-S addr2 CHAR(20);
DCL-S credit PACKED(9:0);
DCL-S bal PACKED(9:0);
DCL-S available PACKED(9:0);
DCL-S found IND;

//=====================================================================
// メインプロシージャ
//=====================================================================

// メインルーチン呼び出し
Main();

// プログラム終了
*INLR = *ON;
RETURN;

//=====================================================================
// メインルーチン
//=====================================================================
DCL-PROC Main;

  // メインループ - F3で終了
  DOW NOT Exit;
    
    // PANEL01（入力画面）表示
    EXFMT PANEL01;
    
    // F3キー（終了）チェック
    IF Exit;
      LEAVE;
    ENDIF;
    
    // 得意先マスターをCHAINで読み込み（元のロジックと同じ）
    CHAIN S1TOKB TOKMSP;
    
    IF %FOUND(TOKMSP);
      // 得意先が見つかった
      // PANEL02のフィールドに値を設定
      S2NAKJ = TKNAKJ;
      S2ADR1 = TKADR1;
      S2ADR2 = TKADR2;
      S2TIKU = TKTIKU;
      S2POST = TKPOST;
      S2GEND = TKGEND;
      S2UZAN = TKUZAN;
      
      // 差額を計算
      S2GAKU = TKGEND - TKUZAN;
      
      // エラー標識クリア
      NotFound = *OFF;
      
      // PANEL01を再表示してからPANEL02を表示
      WRITE PANEL01;
      EXFMT PANEL02;
      
      // PANEL02でF3が押されたかチェック
      IF Exit;
        LEAVE;
      ENDIF;
    ELSE;
      // 得意先が見つからない - エラー標識設定
      NotFound = *ON;
    ENDIF;
    
  ENDDO;

END-PROC;