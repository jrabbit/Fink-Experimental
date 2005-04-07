;; $Id$
;; This configuration is obsolete. Use "carbon-font" shipped with
;; emacs21-carbon >= 20041229-1 instead.
(if (eq window-system 'mac)
    (progn

;; Osaka 12
      (create-fontset-from-fontset-spec
       (concat
	"-*-fixed-medium-r-normal-*-12-*-*-*-*-*-fontset-osaka12,"
	"katakana-jisx0201:-apple-osaka-medium-r-normal--12-120-75-75-m-120-jisx0201.1976-0,"
	"japanese-jisx0208:-apple-osaka-medium-r-normal--12-120-75-75-m-120-jisx0208.1983-sjis,"
	"ascii:-apple-monaco cy-medium-r-normal-*-10-*-*-*-*-*-mac-roman,"
	"latin-iso8859-1:-apple-monaco-medium-r-normal-*-10-*-*-*-*-*-mac-roman"))

;; Osaka 14
      (create-fontset-from-fontset-spec
       (concat
	"-*-fixed-medium-r-normal-*-14-*-*-*-*-*-fontset-osaka14,"
	"katakana-jisx0201:-apple-osaka-medium-r-normal--14-140-75-75-m-140-jisx0201.1976-0,"
	"japanese-jisx0208:-apple-osaka-medium-r-normal--14-140-75-75-m-140-jisx0208.1983-sjis,"
	"ascii:-apple-monaco cy-medium-r-normal-*-12-*-*-*-*-*-mac-roman,"
	"latin-iso8859-1:-apple-monaco-medium-r-normal-*-12-*-*-*-*-*-mac-roman"))

;; Osaka 24
      (create-fontset-from-fontset-spec
       (concat
	"-*-fixed-medium-r-normal-*-24-*-*-*-*-*-fontset-osaka24,"
	"katakana-jisx0201:-apple-osaka-medium-r-normal--24-140-75-75-m-140-jisx0201.1976-0,"
	"japanese-jisx0208:-apple-osaka-medium-r-normal--24-140-75-75-m-140-jisx0208.1983-sjis,"
	"ascii:-apple-courier-medium-r-normal-*-24-240-75-75-m-240-mac-roman,"
	"latin-iso8859-1:-apple-courier-medium-r-normal-*-24-240-75-75-m-240-mac-roman"))

;; HiraKakuGo 12
      (create-fontset-from-fontset-spec
       (concat
	"-*-fixed-medium-r-normal-*-12-*-*-*-*-*-fontset-hirakakugo12,"
	"katakana-jisx0201:-apple-ヒラギノ角ゴ pro w3-medium-r-normal--12-0-75-75-m-0-jisx0201.1976-0,"
	"japanese-jisx0208:-apple-ヒラギノ角ゴ pro w3-medium-r-normal--12-0-75-75-m-0-jisx0208.1983-sjis,"
	"ascii:-apple-monaco cy-medium-r-normal-*-10-*-*-*-*-*-mac-roman,"
	"latin-iso8859-1:-apple-monaco-medium-r-normal-*-10-*-*-*-*-*-mac-roman"))

;; HiraKakuGo 14
      (create-fontset-from-fontset-spec
       (concat
	"-*-fixed-medium-r-normal-*-14-*-*-*-*-*-fontset-hirakakugo14,"
	"katakana-jisx0201:-apple-ヒラギノ角ゴ pro w3-medium-r-normal--14-0-75-75-m-0-jisx0201.1976-0,"
	"japanese-jisx0208:-apple-ヒラギノ角ゴ pro w3-medium-r-normal--14-0-75-75-m-0-jisx0208.1983-sjis,"
	"ascii:-apple-monaco cy-medium-r-normal-*-12-*-*-*-*-*-mac-roman,"
	"latin-iso8859-1:-apple-monaco-medium-r-normal-*-12-*-*-*-*-*-mac-roman"))

;; HiraMin 12
      (create-fontset-from-fontset-spec
       (concat
	"-*-fixed-medium-r-normal-*-12-*-*-*-*-*-fontset-hiramin12,"
	"katakana-jisx0201:-apple-ヒラギノ明朝 pro w3-medium-r-normal--12-0-75-75-m-0-jisx0201.1976-0,"
	"japanese-jisx0208:-apple-ヒラギノ明朝 pro w3-medium-r-normal--12-0-75-75-m-0-jisx0208.1983-sjis,"
	"ascii:-apple-monaco cy-medium-r-normal-*-10-*-*-*-*-*-mac-roman,"
	"latin-iso8859-1:-apple-monaco-medium-r-normal-*-10-*-*-*-*-*-mac-roman"))

;; HiraMin 14
      (create-fontset-from-fontset-spec
       (concat
	"-*-fixed-medium-r-normal-*-14-*-*-*-*-*-fontset-hiramin14,"
	"katakana-jisx0201:-apple-ヒラギノ明朝 pro w3-medium-r-normal--14-0-75-75-m-0-jisx0201.1976-0,"
	"japanese-jisx0208:-apple-ヒラギノ明朝 pro w3-medium-r-normal--14-0-75-75-m-0-jisx0208.1983-sjis,"
	"ascii:-apple-monaco cy-medium-r-normal-*-12-*-*-*-*-*-mac-roman,"
	"latin-iso8859-1:-apple-monaco-medium-r-normal-*-12-*-*-*-*-*-mac-roman"))

      )
  )

(provide 'appleotffonts-ja)
