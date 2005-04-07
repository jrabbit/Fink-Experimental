;;; -*- coding: iso-2022-7bit -*-
;;; utf-8m.el --- Unicode one-way converter (NRD -> NRC)
;;; Based on mac-utf.el by Zenitani and modified by Todai Fink Team.

;; Copyright (C) 2004-2005  Seiji Zenitani <zenitani@mac.com>

;; Author: Seiji Zenitani <zenitani@mac.com>
;; Version: v20050129
;; Keywords: mac, multilingual, Unicode, UTF-8
;; Created: 2004-02-20
;; Compatibility: Mac OS X (Carbon Emacs)
;; URL(jp): http://macwiki.sourceforge.jp/cgi-bin/wiki.cgi?CarbonEmacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This package provides post-read converter functions for Emacs.
;; The following characters are converted from UTF8-NRD (Normalization
;; form D) format to popular UTF8-NRC (Normalization form C) format.
;; 
;;  * Japanese kana characters with dakuten/han-dakuten signs
;;  * Korean Hangul characters
;;
;; In order to use, add the below lines to your .emacs file
;; before you declare your language environment.
;; 
;;   (require 'utf-8m)
;;   (set-language-environment 'Japanese) ; or 'Korean)
;;
;; Note that this code provides one-way conversion from UTF8-NRD to UTF8-NRC,
;; and that reverse conversion (UTF8-NRC -> UTF8-NRD) is not provided.

;;; utf-8m について

;; Mac OS X の HFS+ ファイルシステムのファイル名を読むために
;; Emacs の Unicode エンコーディングを修正します。
;; 日本語の濁点・半濁点文字とハングル文字に対応しています。
;; オリジナルの mac-utf は Mule-UCS に依存していますが、
;; この utf-8m は Emacs 組み込みの Unicode サポートに基づいています。


;;; Code:

(make-coding-system
  'utf-8m 4 ?u
  "modified UTF-8 encoding for Mac OS X hfs plus volume format."
  '(ccl-decode-mule-utf-8 . ccl-encode-mule-utf-8)
  '((safe-charsets
     ascii
     eight-bit-control
     eight-bit-graphic
     latin-iso8859-1
     mule-unicode-0100-24ff
     mule-unicode-2500-33ff
     mule-unicode-e000-ffff)
    (mime-charset . utf-8)
    (coding-category . coding-category-utf-8)
    (valid-codes (0 . 255))
    (post-read-conversion . utf-8m-post-read-conversion) ; <== modified
    (translation-table-for-encode . utf-translation-table-for-encode)
    (dependency unify-8859-on-encoding-mode
                unify-8859-on-decoding-mode
                utf-fragment-on-decoding
                utf-translate-cjk)))


;; for Japanese kana characters with dakuten/han-dakuten signs

(defvar utf-8m-fix-kana1-alist
  '( ?か ?き ?く ?け ?こ ?さ ?し ?す ?せ ?そ
     ?た ?ち ?つ ?て ?と ?は ?ひ ?ふ ?へ ?ほ
     ?カ ?キ ?ク ?ケ ?コ ?サ ?シ ?ス ?セ ?ソ
     ?タ ?チ ?ツ ?テ ?ト ?ハ ?ヒ ?フ ?ヘ ?ホ
     ?ヽ ?ゝ ))
(defvar utf-8m-fix-kana2-alist
  '( ?は ?ひ ?ふ ?へ ?ほ ?ハ ?ヒ ?フ ?ヘ ?ホ ))

(defun utf-8m-post-read-kana-conversion (length)
  "Document forthcoming..."
  (save-excursion
    (while (not (eobp))
      (let ((ch1 (char-before))
            (ch2 (char-after)))
        (cond
         ((= ch2 302969)
          (cond
           ((memq ch1 utf-8m-fix-kana1-alist)
            (delete-char -1)
            (delete-char 1)
            (insert (+ ch1 1))
            (setq length (- length 1))
            )
           ((= ch1 ?ウ)
            (delete-char -1)
            (delete-char 1)
            (insert ?ヴ)
            (setq length (- length 1))
            )))
          ((= ch2 302970)
           (cond
            ((memq ch1 utf-8m-fix-kana2-alist)
             (delete-char -1)
             (delete-char 1)
             (insert (+ ch1 2))
             (setq length (- length 1))
             ))))
        (if (not (eobp))(forward-char))
        )))
  length)


;; for Korean Hangul characters
;; ref. http://www.unicode.org/reports/tr15/#Hangul

(defun utf-8m-post-read-hangul-conversion (length)
  "Document forthcoming..."
  (save-excursion
    (let* ((ch1 nil)
           (ch2 nil)
           (sbase #xac00)
           (lbase #x1100)
           (vbase #x1161)
           (tbase #x11a7)
           (lcount 19)
           (vcount 21)
           (tcount 28)
           (ncount (* vcount tcount)) ; 588
           (scount (* lcount ncount)) ; 11172
           (lindex nil)
           (vindex nil)
           (sindex nil)
           (tindex nil))

      (setq ch1 (encode-char (char-after) 'ucs))
      (if (not (eobp))(forward-char))

      (while (not (eobp))

        (setq ch2 (encode-char (char-after) 'ucs))
;       (message "ch1:%X ch2:%X" ch1 ch2)
        (setq lindex (- ch1 lbase))
        (setq vindex (- ch2 vbase))
        (setq sindex (- ch1 sbase))
        (setq tindex (- ch2 tbase))

        (if (and (>= lindex 0)(< lindex lcount)
                 (>= vindex 0)(< vindex vcount))
            (progn
;             (message "first loop")
              (setq ch1 (+ sbase (* (+ (* lindex vcount) vindex) tcount)))
              (delete-char -1)
              (delete-char 1)
              (insert (encode-char 'ucs ch1))
              (setq length (- length 1))
              )
          (if (and (>= sindex 0)(< sindex scount)
                   (= (% sindex tcount) 0)
                   (>= tindex 0)(< tindex tcount))
              (progn
;               (message "second loop")
                (setq ch1 (+ ch1 tindex))
                (delete-char -1)
                (delete-char 1)
                (insert (encode-char 'ucs ch1))
                (setq length (- length 1))
                )
            (progn
              (setq ch1 ch2)
              (if (not (eobp))(forward-char))
              )
            ))
        
        )))
  length)


;; use the above functions as post-read-converter

(defun utf-8m-post-read-conversion (length)
   "Document forthcoming..."
   (mapc (lambda (fn) (setq length (funcall fn length)))
	 '(utf-8-post-read-conversion
	   utf-8m-post-read-kana-conversion
	   utf-8m-post-read-hangul-conversion))
   length)

(provide 'utf-8m)

;; utf-8m.el ends here.
