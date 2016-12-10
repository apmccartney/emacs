(global-set-key (kbd "S-<Delete>") 'delete-forward-char)
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-c c") 'cmake-ide-compile)
(global-set-key (kbd "C-c s") 'rtags-find-symbol)
(global-set-key (kbd "C-c r") 'rtags-find-references)

(column-number-mode)
(setq-default truncate-lines 0)
(setq linum-format "%3d│ ")
(setq fci-rule-column 80)
(setq fci-rule-width 5)
(setq fci-rule-color "red")

(require 'package)

(setq url-proxy-services
   '(("no_proxy" . "^\\(localhost\\|10.*\\)")
     ("http" . "proxyout.lanl.gov:8080")
     ("https" . "proxyout.lanl.gov:8080")))

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(load-theme 'monokai t)

(exec-path-from-shell-initialize)
(require 'rtags) ;; optional, must have rtags installed
(require 'cmake-ide)
(cmake-ide-setup)

(c-add-style "njoy21"
	     '("stroustrup"
	       (c-basic-offset . 2)
	       (c-offsets-alist
		(innamespace - ))))
(setq c-default-style "njoy21")

(defun njoy21-hook ()
  "Initialization for CC-mode runs before other hooks"
  (c-set-style "njoy21")
  (linum-mode)
  (setq truncate-lines 1)
  (setq c-doc-comment-style
        '((java-mode . javadoc)
          (c-mode    . javadoc)
          (c++-mode  . javadoc))))
(add-hook 'c-mode-hook 'njoy21-hook)
(add-hook 'c++-mode-hook 'njoy21-hook)
;;(add-hook 'c++-mode-hook 'fci-mode)
(add-hook 'c++-mode-hook 'subword-mode)

;; =============
;; irony-mode
;; =============
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
;; =============
;; company mode
;; =============
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'company-mode)
;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
(define-key irony-mode-map [remap completion-at-point]
  'irony-completion-at-point-async)
(define-key irony-mode-map [remap complete-symbol]
  'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(eval-after-load 'company
'(add-to-list 'company-backends 'company-irony))
;; (optional) adds CC special commands to `company-begin-commands' in order to
;; trigger completion at interesting places, such as after scope operator
;;     std::|
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
;; =============
;; flycheck-mode
;; =============
(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'c-mode-hook 'flycheck-mode)
(eval-after-load 'flycheck
'(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
;; =============
;; eldoc-mode
;; =============
(add-hook 'irony-mode-hook 'irony-eldoc)
;; ==========================================
;; (optional) bind TAB for indent-or-complete
;; ==========================================
(defun irony--check-expansion ()
(save-excursion
  (if (looking-at "\\_>") t
    (backward-char 1)
    (if (looking-at "\\.") t
      (backward-char 1)
      (if (looking-at "->") t nil)))))
(defun irony--indent-or-complete ()
"Indent or Complete"
(interactive)
(cond ((and (not (use-region-p))
            (irony--check-expansion))
       (message "complete")
       (company-complete-common))
      (t
       (message "indent")
       (call-interactively 'c-indent-line-or-region))))
(defun irony-mode-keys ()
"Modify keymaps used by `irony-mode'."
(local-set-key (kbd "TAB") 'irony--indent-or-complete)
(local-set-key [tab] 'irony--indent-or-complete))
(add-hook 'c-mode-common-hook 'irony-mode-keys)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
