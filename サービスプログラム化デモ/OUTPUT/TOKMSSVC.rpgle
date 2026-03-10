**FREE

//=====================================================================
// サービスプログラム: TOKMSSVC
// 説明: 得意先マスタ共通サービス
// 作成者: IBM i 開発チーム
// 作成日: 2026-02-24
//=====================================================================

CTL-OPT NOMAIN;

// ファイル宣言
DCL-F TOKMSP DISK KEYED USAGE(*INPUT);

//=====================================================================
// プロトタイプ: GETCUSTOMER
// 説明: 得意先情報取得
// パラメータ:
//   customerNo   - 得意先番号（入力）
//   customerName - 得意先名（出力）
//   address1     - 住所1（出力）
//   address2     - 住所2（出力）
//   creditLimit  - 信用限度額（出力）
//   balance      - 売掛残高（出力）
// 戻り値: *ON=成功, *OFF=該当なし
//=====================================================================
DCL-PR GETCUSTOMER IND;
  customerNo CHAR(5) CONST;
  customerName CHAR(20);
  address1 CHAR(20);
  address2 CHAR(20);
  creditLimit PACKED(9:0);
  balance PACKED(9:0);
END-PR;

//=====================================================================
// プロトタイプ: CALCAVAILABLE
// 説明: 利用可能額計算
// パラメータ:
//   customerNo - 得意先番号（入力）
// 戻り値: 利用可能額（限度額 - 売掛残高）
//=====================================================================
DCL-PR CALCAVAILABLE PACKED(9:0);
  customerNo CHAR(5) CONST;
END-PR;

//=====================================================================
// プロシージャ: GETCUSTOMER
// 説明: TOKMSPファイルから得意先情報を取得
//=====================================================================
DCL-PROC GETCUSTOMER EXPORT;
  DCL-PI *N IND;
    customerNo CHAR(5) CONST;
    customerName CHAR(20);
    address1 CHAR(20);
    address2 CHAR(20);
    creditLimit PACKED(9:0);
    balance PACKED(9:0);
  END-PI;

  // 得意先マスタをキーで読み込み
  CHAIN customerNo TOKMSP;
  
  IF %FOUND(TOKMSP);
    // 得意先が見つかった - 出力パラメータに設定
    customerName = TKNAKJ;
    address1 = TKADR1;
    address2 = TKADR2;
    creditLimit = TKGEND;
    balance = TKUZAN;
    RETURN *ON;
  ELSE;
    // 得意先が見つからない
    RETURN *OFF;
  ENDIF;
  
END-PROC;

//=====================================================================
// プロシージャ: CALCAVAILABLE
// 説明: 利用可能額を計算
//=====================================================================
DCL-PROC CALCAVAILABLE EXPORT;
  DCL-PI *N PACKED(9:0);
    customerNo CHAR(5) CONST;
  END-PI;

  DCL-S available PACKED(9:0);

  // 得意先マスタをキーで読み込み
  CHAIN customerNo TOKMSP;
  
  IF %FOUND(TOKMSP);
    // 計算: 信用限度額 - 売掛残高
    available = TKGEND - TKUZAN;
  ELSE;
    // 得意先が見つからない - 0を返す
    available = 0;
  ENDIF;

  RETURN available;
  
END-PROC;