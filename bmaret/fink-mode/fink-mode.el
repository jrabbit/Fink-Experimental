;;; fink-mode-el -- Major mode for editing Fink info files

;; Author: Sebastien Maret <bmaret@users.sf.net>
;; Keywords: Fink major-mode

;; Copyright (C) 2006-2007 Sebastien Maret

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA

;; TODO:
;; 
;; * Find the correct regexp to higlight versions numbers and
;;   and pseudo hashes					 
;;
;; * Install, Remove, Build, Rebuild: write a function to find
;;   the package name. We still need to ask for user confirmation
;;   because some package may have variants that whose name won't
;;   be easy to resolve.
;;
;; * Install, Remove, Build, Rebuild, Selfupdate, Index: find 
;;   a way to start a new process that does not hang when asking
;;   for a password.
;;
;; * Allow user to customize the syntax highlingting level and
;;   the tab space for indentation
;;
;;; Code:

(require 'easymenu)
(require 'font-lock)

(defvar fink-mode-hook nil)
(defvar fink-mode-map
  (let ((fink-mode-map (make-keymap)))
    (define-key fink-mode-map "\C-j" 'newline-and-indent)
    fink-mode-map)
  "Keymap for Fink major mode")

(add-to-list 'auto-mode-alist '("\\.info\\'" . fink-mode))

(defconst fink-fields
  '("Package" "Version" "Revision" "Architecture" "Epoch"
    "Description" "Type" "License" "Maintainer" "Info2" "Depends"
    "BuildDepends" "Provides" "Conflicts" "BuildConflicts" "Replaces"
    "Recommends" "Suggests" "Enhances" "Pre-Depends" "Essential"
    "BuildDependsOnly" "CustomMirror" "Source" "Source2" "Source3"
    "SourceDirectory" "NoSourceDirectory" "Source2ExtractDir"
    "Source3ExtractDir" "SourceRename" "Source2Rename" "Source3Rename"
    "Source-MD5" "Source2-MD5" "Source3-MD5" "TarFilesRename"
    "Tar2FilesRename" "Tar3FilesRename" "UpdateConfigGuess"
    "UpdateConfigGuessInDirs" "UpdateLibtool" "UpdateLibtoolInDirs"
    "UpdatePoMakefile" "Patch" "PatchFile" "PatchFile-MD5"
    "PatchScript" "SetCC" "SetCFLAGS" "SetCPP" "SetCPPFLAGS" "SetCXX"
    "SetCXXFLAGS" "SetDYLD_LIBRARY_PATH" "SetJAVA_HOME"
    "SetLD_PREBIND" "SetLD_PREBIND_ALLOW_OVERLAP"
    "SetLD_FORCE_NO_PREBIND" "SetLD_SEG_ADDR_TABLE" "SetLD"
    "SetLDFLAGS" "SetLIBRARY_PATH" "SetLIBS"
    "SetMACOSX_DEPLOYMENT_TARGET" "SetMAKE" "SetMFLAGS" "SetMAKEFLAGS"
    "NoSetCC" "NoSetCFLAGS" "NoSetCPP" "NoSetCPPFLAGS" "NoSetCXX"
    "NoSetCXXFLAGS" "NoSetDYLD_LIBRARY_PATH" "NoSetJAVA_HOME"
    "NoSetLD_PREBIND" "NoSetLD_PREBIND_ALLOW_OVERLAP"
    "NoSetLD_FORCE_NO_PREBIND" "NoSetLD_SEG_ADDR_TABLE" "NoSetLD"
    "NoSetLDFLAGS" "NoSetLIBRARY_PATH" "NoSetLIBS"
    "NoSetMACOSX_DEPLOYMENT_TARGET" "NoSetMAKE" "NoSetMFLAGS"
    "NoSetMAKEFLAGS" "ConfigureParams" "GCC" "CompileScript"
    "NoPerlTests" "InfoTest" "TestScript" "TestConfigureParams"
    "TestDepends" "TestConflicts" "TestSource" "TestSource2"
    "TestSource3" "TestSourceDirectory" "TestNoSourceDirectory"
    "TestSource2ExtractDir" "TestSource3ExtractDir" "TestSourceRename"
    "TestSource2Rename" "TestSource3Rename" "TestSource-MD5"
    "TestSource2-MD5" "TestSource3-MD5" "TestTarFilesRename"
    "TestTar2FilesRename" "TestTar3FilesRename" "TestSuiteSize"
    "UpdatePOD" "InstallScript" "JarFiles" "AppBundles" "DocFiles"
    "Shlibs" "RuntimeVars" "SplitOff" "SplitOff2" "SplitOff2"
    "SplitOff4" "SplitOff5" "Files" "PreInstScript" "PostInstScript"
    "PreRmScript" "PostRmScript" "ConfFiles" "InfoDocs" "DaemonicFile"
    "DaemonicName" "Homepage" "DescDetail" "DescUsage" "DescPackaging"
    "DescPort")
  "List of Fink fields")

(defconst fink-field-regexp
  (concat "\\<\\(" (regexp-opt fink-fields) "\\)\\>")
  "Regexp for Fink fields names.")

(defconst fink-percent-expansions
  '("%n" "%N" "%e" "%v" "%V" "%r" "%f" "%p" "%P" "%d" "%D" "%i" "%I"
     "%a" "%b" "%c" "%m" "%%" "%type_raw" "%type_pkg" "%{ni}" "%{Ni}"
     "%{default_script}" "%{PatchFile}" "%lib")
   "List of Fink percent expansions")

(defconst fink-percent-expansion-regexp
  (concat "\\(" (regexp-opt fink-percent-expansions) "\\)")
  "Regexp for Fink percent expansions.")

(defconst fink-font-lock-keywords-1
  (list
   fink-field-regexp '(1 font-lock-function-name-face))
  "Highlight fields names in Fink mode.")

(defconst fink-font-lock-keywords-2
  (list 
   (list fink-field-regexp '(1 font-lock-function-name-face))
   (list fink-percent-expansion-regexp '(1 font-lock-variable-name-face)))
  "Highlight fields names and percent expansion variables in Fink.")

(defconst fink-font-lock-keywords-3
  (list 
   (list fink-field-regexp '(1 font-lock-function-name-face))
   (list fink-percent-expansion-regexp '(1 font-lock-variable-name-face))
   '("\([a-z0-9A-Z<>.-]\)" (1 font-lock-constant-face)))
  "Highlighting fields names, percent expansion variables, versions number and pseudo-hashes.")

(defvar fink-font-lock-keywords fink-font-lock-keywords-2
  "Default highlighting level for Fink mode.")

;(defvar fink-mode-syntax-table
;  (let ((fink-mode-syntax-table (make-syntax-table)))
;    (modify-syntax-entry ?\# "<") fink-mode-syntax-table
;    (modify-syntax-entry ?\n ">#") fink-mode-syntax-table
;    fink-mode-syntax-table)
;  "Syntax table for Fink mode")

(defvar fink-indent-width 2
  "Default indent width for Fink mode.")

(defun fink-indent-line ()
  (interactive)
  (beginning-of-line)
  (if (bobp)
      (indent-line-to 0)
    (let ((not-indented t) cur-indent)
      (if (looking-at "^[ \t]*\<\<")
	  (progn
	    (save-excursion
	      (forward-line -1)
	      (setq cur-indent (- (current-indentation) fink-indent-width)))
	    (if (< cur-indent 0)
		(setq cur-indent 0)))
		(save-excursion
		  (while not-indented
		    (forward-line -1)
		    (if (looking-at "^[ \t]*\<\<")
			(progn
			  (setq cur-indent (current-indentation))
			  (setq not-indented nil))
		      (if (looking-at "^[ \t]*[a-z0-9A-Z]*\:[ \t]*\<\<")
			  (progn
			    (setq cur-indent (+ (current-indentation) fink-indent-width))
			    (setq not-indented nil))
			(if (bobp)
			    (setq not-indented nil)))))))
      (if cur-indent
	  (indent-line-to cur-indent)
	(indent-line-to 0))))
  "Indent line in Fink mode.")
      
(defun fink-package-names ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (when (looking-at "^\\(Depends\\|BuildDepends\\):\\s-*\\([-a-zA-Z0-9+.]+?\\)\\s-*$")
          (push (concat
                 (if (save-match-data (string-match "Source" (match-string 1)))
                     "src:"
                   "")
                 (match-string-no-properties 2)) result))
        (forward-line 1)))
    result))

(defun fink-install-package (package)
  "Install a Fink package" 
  (interactive
   (list
    (completing-read "Install package: "
                     (mapcar #'(lambda (x) (cons x 0))
                             (fink-package-names))
                     nil t)))
  (interactive)
  (shell-command (concat "fink install " package)))

(defun fink-remove-package (package)
  "Install a Fink package" 
  (interactive
   (list
    (completing-read "Remove package: "
                     (mapcar #'(lambda (x) (cons x 0))
                             (fink-package-names))
                     nil t)))
  (interactive)
  (shell-command (concat "fink remove " package)))

(defun fink-update-package (package)
  "Install a Fink package" 
  (interactive
   (list
    (completing-read "Update package: "
                     (mapcar #'(lambda (x) (cons x 0))
                             (fink-package-names))
                     nil t)))
  (interactive)
  (shell-command (concat "fink install " package)))

(defun fink-build-package (package)
  "Install a Fink package" 
  (interactive
   (list
    (completing-read "Install package: "
                     (mapcar #'(lambda (x) (cons x 0))
                             (fink-package-names))
                     nil t)))
  (interactive)
  (shell-command (concat "fink install " package)))

(defun fink-rebuild-package (package)
  "Install a Fink package" 
  (interactive
   (list
    (completing-read "Install package: "
                     (mapcar #'(lambda (x) (cons x 0))
                             (fink-package-names))
                     nil t)))
  (interactive)
  (shell-command (concat "fink install " package)))

(defun fink-selfupdate ()
  "Upgrade Fink"
  (interactive)
  (shell-command "fink selfupdate"))

(defun fink-index ()
  "Rebuild Fink index"
  (interactive)
  (start-process "fink" "Fink-interaction" "fink" "index"))

(defun fink-validate ()
  "Validate Fink package"
  (interactive)
  (shell-command (concat "fink validate " buffer-file-name)))

(defun fink-search-database-package (package)
  "Search for a package in Fink web database"
  (interactive
   (list
    (completing-read "Search database for package: "
                     (mapcar #'(lambda (x) (cons x 0))
                             (fink-package-names))
                     nil t)))
  (browse-url (concat "http://pdb.finkproject.org/pdb/search.php?summary=" package)))

(defun fink-read-users-guide ()
  "Read the Fink User's Guide"
  (require 'browse-url)
  (browse-url  "http://finkproject.org/doc/users-guide/index.php"))

(defun fink-read-packaging-tutorial ()
  "Read the Fink Packaging Tutorial"
  (require 'browse-url)
  (browse-url  "http://finkproject.org/doc/quick-start-pkg/index.php"))

(defun fink-read-packaging-manual ()
  "Read the Fink Packaging Manual"
  (require 'browse-url)
  (browse-url  "http://finkproject.org/doc/packaging/index.php"))

(defun fink-visit-devel-wiki ()
  "Visit Fink Developers Wiki"
  (require 'browse-url)
  (browse-url  "http://wiki.finkproject.org/index.php/Fink"))

(easy-menu-define
  fink-mode-menu fink-mode-map "Fink Mode Menu"
  '("Fink"
    ["Install Package" fink-install-package t]
    ["Remove Package" fink-remove-package t]
    ["Update Package" fink-update-package t]
    ["Build Package" fink-build-package t]
    ["Rebuild Package" fink-rebuild-package t]
    ["Self Update Fink" (fink-selfupdate) t]
    ["Rebuild Index" (fink-index) t]
    ["Validate Package" (fink-validate) t]
    "--"
    ["Search Database" fink-search-database-package t]
    ["Read Fink User's Guide" (fink-read-users-guide) t]
    ["Read Fink Packaging Tutorial" (fink-read-packaging-tutorial) t]
    ["Read Packaging Manual" (fink-read-packaging-manual) t]
    ["Visit Fink Developers Wiki" (fink-visit-devel-wiki) t]
    "--"
    ["Customize" (customize-group "fink") t]))
 
(defun fink-mode ()
  (interactive)
  (kill-all-local-variables)
  (use-local-map fink-mode-map)
;;  (set-syntax-table fink-mode-syntax-table)
  (set (make-local-variable 'font-lock-defaults) '(fink-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'fink-indent-line)
  (setq major-mode 'fink-mode)
  (setq mode-name "Fink")
  (add-hook 'fink-mode-hook 'goto-address)
  (run-hooks 'fink-mode-hook))


(provide 'fink-mode)

;;; fink-mode.el ends here



