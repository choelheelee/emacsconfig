;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load-theme 'tango-dark)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; package install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(setq package-enable-at-startup nil)
(package-initialize)

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.
Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

; Make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

; Activate installed packages
(package-initialize)

; Assuming you wish to install packages
(ensure-package-installed   'evil
                            'evil-surround
                        ;;  'flycheck
                        ;;  'projectile
                        ;;  'iedit
                            'auto-complete
                            'ac-c-headers
                            'auto-complete-c-headers
                            'auto-complete-exuberant-ctags
                            'yasnippet
                            'helm
                            'ggtags    ; install gnu ggtags
                        ;;  'perspective
                        ;;  'persp-projectile
                        ;;  'helm-projectile
                            'linum-relative
                            'smart-tabs-mode
                            'magit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; turn on evil mode 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(evil-mode t)
; evil-surround
; surrounding?
; see http://www.vim.org/scripts/script.php?script_id=1697
(require 'evil-surround)
(global-evil-surround-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; show matching parenthesis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(show-paren-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; line number - relative
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-linum-mode t)
(require 'linum-relative)
; use relative line number, but shows current line number instead of 0
(with-eval-after-load 'linum
  (set-face-background 'linum nil)

  (require 'linum-relative)

  ;; truncate current line to four digits
  (defun linum-relative (line-number)
    (let* ((diff1 (abs (- line-number linum-relative-last-pos)))
	   (diff (if (minusp diff1)
		     diff1
		   (+ diff1 linum-relative-plusp-offset)))
	   (current-p (= diff linum-relative-plusp-offset))
	   (current-symbol (if (and linum-relative-current-symbol current-p)
			       (if (string= "" linum-relative-current-symbol)
				   (number-to-string (% line-number 1000))
				 linum-relative-current-symbol)
			     (number-to-string diff)))
	   (face (if current-p 'linum-relative-current-face 'linum)))
      (propertize (format linum-relative-format current-symbol) 'face face)))


  (setq
   linum-relative-current-symbol ""
   linum-relative-format "%3s "
   linum-delay t)

  (set-face-attribute 'linum-relative-current-face nil
		      :weight 'extra-bold
		      :foreground nil
		      :background nil
		          :inherit '(hl-line default)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yasnippet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'yasnippet)
(yas-global-mode 1)

(require 'yasnippet)
(setq yas-snippet-dirs '("~/.emacs.d/snippets"
                         "~/.emacs.d/remote-snippets"))
(yas-reload-all)
; (define-key yas-minor-mode-map (kbd "<tab>") nil)
; (define-key yas-minor-mode-map (kbd "TAB") nil)
; (setq tab-always-indent 'yas-expand)
; (define-key yas-minor-mode-map (kbd "C-l") 'yas-expand)
(define-key yas-minor-mode-map (kbd "<escape>") 'yas-exit-snippet)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq helm-buffers-fuzzy-matching t)
(helm-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; indentation style for c, c++, java
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq c-default-style "linux"
      c-basic-offset 4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start emacs gui with full screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(send-mail-function nil)
 '(speedbar-frame-parameters
   (quote
    ((minibuffer)
     (width . 50)
     (border-width . 0)
     (menu-bar-lines . 0)
     (tool-bar-lines . 0)
     (unsplittable . t)
     (left-fringe . 0))))
 '(speedbar-show-unknown-files t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; don't make backup files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq make-backup-files nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto complete 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)
; header name auto completion
(require 'auto-complete-c-headers)
(add-to-list 'ac-sources 'ac-source-c-headers)
; ctag auto completion
(require 'auto-complete-exuberant-ctags)
(ac-exuberant-ctags-setup)
; add semantic to autocomplete
; https://www.youtube.com/watch?v=Ib914gNr0ys
(semantic-mode 1)
(defun my:add-semantic-to-autocomplete()
  (add-to-list 'ac-sources 'ac-source-semantic))
(add-hook 'c-mode-common-hook 'my:add-semantic-to-autocomplete)
(global-ede-mode 1)
; add system include for semantic
(semantic-add-system-include "/usr/local/include/boost" 'c++-mode) 
(semantic-add-system-include "/usr/include/c++/4.2.1" 'c++-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; alias or path or key binding, etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defalias 'hff 'helm-find-files)               ; helm find files
(global-set-key [f3] 'speedbar)                ; speedbar - show dir/file tree
(global-set-key [f4] 'apropos-command)         ; find full command name by regex
;(global-set-key [f5] 'semantic-symref)        ; for function call hierarchy
;(global-set-key [f6] 'semantic-symref-symbol) ; for function call hierarchy
(global-set-key [f5] 'ggtags-find-file)        ; find file using regular expression
(global-set-key [f6] 'ggtags-find-reference)   ; find function call references
;(global-set-key [f7] 'previous-error)          ; for compile error debugging
(global-set-key [f7] 'ggtags-grep)             ; for grep tag
(global-set-key [f8] 'next-error)              ; for compile error debugging
(global-set-key [f9] 'compile)                 ; for compile
;;(global-set-key [f12] 'ggtags-find-tag-dwim)   ; find tags of current point
(global-set-key (kbd "S-<right>") 'ggtags-find-tag-dwim)   ; find tags of current point
(setq default-frame-alist '((background-color . "black")))

(global-set-key (kbd "C-S-<up>") 'windmove-up)
(global-set-key (kbd "C-S-<down>") 'windmove-down)
(global-set-key (kbd "C-S-<left>") 'windmove-left)
(global-set-key (kbd "C-S-<right>") 'windmove-right)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gdb use many windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq gdb-many-windows t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; scrolling to automatically display new output
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq compilation-scroll-output t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; automatically give a current buffer's filename
;; when executing compile-command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'c++-mode-hook
  (lambda ()
    (set (make-local-variable 'compile-command)
         (format "g++ -g -Wall -O0 -std=c++11 -fno-elide-constructors %s" (buffer-name)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smart-tabs-mode : http://www.emacswiki.org/emacs/SmartTabs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(smart-tabs-insinuate 'c 'javascript)
(smart-tabs-add-language-support c++ c++-mode-hook
  ((c-indent-line . c-basic-offset)
   (c-indent-region . c-basic-offset)))
(setq-default tab-width 4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use spaces instead of tabs : http://www.emacswiki.org/emacs/NoTabs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default indent-tabs-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; map file type to mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq auto-mode-alist
      (append
       '(("\\.C$" . c++-mode)
         ("\\.H$" . c++-mode)
         ("\\.cc$" . c++-mode)
         ("\\.cpp$" . c++-mode)
         ("\\.hh$" . c++-mode)
         ("\\.c$" . c-mode)
         ("\\.h$" . c++-mode)
         ("\\.i$" . c++-mode)
         ("\\.l$" . c++-mode)
         ("\\.gc$" . c-mode)
         ("\\.pc$" . c-mode)
         ("\\.inl$" . c++-mode)
         ("\\.py$" . python-mode)
         ("SConstruct$" . python-mode)
         ("Makefile.$" . makefile-mode)
         ("makefile.$" . makefile-mode)
         (".emacs" . lisp-mode))
       auto-mode-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; inhibit open startup screen - open just edit screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-screen t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ggtags mode
;;  - install global (gtags binary is also installed)
;;  - execute gtags at the top dir of src
;;  - M-x ggtags-mode
;;  - shift + mouse button click
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'c-mode-common-hook
  (lambda () (ggtags-mode 1)))
(add-hook 'c++-mode-hook
  (lambda () (ggtags-mode 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; let emacs know executables path
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(setq exec-path (split-string (getenv "PATH") ":"))
(setq exec-path (append exec-path '("/usr/local/bin")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Change frame backgroup color
;; You can rgb value of colors in M-x list-colors-display
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'default-frame-alist '(background-color . "#1F1F1F"))
