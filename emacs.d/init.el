;; Douglas Anderson's emacs.d/init.el file
;; Additions from:
;;  - Ryan Barrett's .emacs  (https://snarfed.org/dotfiles/.emacs)
;;  - http://clojure-doc.org/articles/tutorials/emacs.html

(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(defvar my-packages '(better-defaults
                      exec-path-from-shell
                      clojure-mode
                      clojure-test-mode
                      cider
                      magit
                      haskell-mode
                      flycheck
                      flycheck-rust
                      flycheck-pyflakes
                      rust-mode))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

;; turn off toolbar and menubar and scrollbar!
(when window-system
  (if (fboundp 'menu-bar-mode)
      (menu-bar-mode 0))
  (if (fboundp 'tool-bar-mode)
      (tool-bar-mode 0))
  (if (fboundp 'scroll-bar-mode)
      (scroll-bar-mode -1))
  (tooltip-mode 0))

; avoid garbage collection up to 10M (default is only 400k)
(setq-default gc-cons-threshold 10000000)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (wombat))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; inherit PATH var from shell (https://github.com/purcell/exec-path-from-shell)
(require 'exec-path-from-shell)
(exec-path-from-shell-initialize)

(setenv "PAGER" "cat")

(defvar local-shells
  '("*shell0*" "*shell1*" "*shell2*" "*shell3*"))

(custom-set-variables
 '(comint-scroll-to-bottom-on-input t)  ; always insert at the bottom
 '(comint-scroll-to-bottom-on-output nil) ; always add output at the bottom
 '(comint-scroll-show-maximum-output t) ; scroll to show max possible output
 ;; '(comint-completion-autolist t)     ; show completion list when ambiguous
 '(comint-input-ignoredups t)           ; no duplicates in command history
 '(comint-completion-addsuffix t)       ; insert space/slash after file completion
 '(comint-buffer-maximum-size 10000)    ; max length of the buffer in lines
 '(comint-prompt-read-only nil)         ; if this is t, it breaks shell-command
 '(comint-input-ring-size 1000)         ; max shell history size
 '(comint-get-old-input (lambda () "")) ; what to run when i press enter on a
                                        ; line above the current prompt
)

;; truncate buffers continuously
(add-hook 'comint-output-filter-functions 'comint-truncate-buffer)

; interpret and use ansi color codes in shell buffers
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(defun make-my-shell-output-read-only (text)
  "Add output-filter-functions to make stdout read only in my shells."
  (if (member (buffer-name) local-shells)
      (let ((inhibit-read-only t)
            (output-end (process-mark (get-buffer-process (current-buffer)))))
        (put-text-property comint-last-output-start output-end 'read-only t))))
(add-hook 'comint-output-filter-functions 'make-my-shell-output-read-only)

(defun set-scroll-conservatively ()
  "Add to shell-mode-hook to prevent jump-scrolling on newlines in shell."
  (set (make-local-variable 'scroll-conservatively) 20))
(add-hook 'shell-mode-hook 'set-scroll-conservatively)

;; run a few shells.
(defun start-shells ()
  (interactive)
  (let ((default-directory "~")
        ;; trick comint into thinking the current window is 80 columns, since it
        ;; uses that to set the COLUMNS env var. otherwise it uses whatever the
        ;; current window's width is, which could be anything.
        (window-width (lambda () 80)))
    (mapcar 'shell local-shells)))

(defun fix-shell ()
  "Sometimes the input area of a shell buffer goes read only. This fixes that."
  (interactive)
  (let ((inhibit-read-only t))
    (comint-send-input)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Programming
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'flycheck)

; Use sh-mode for Dockerfile
(add-to-list 'auto-mode-alist '("Dockerfile" . sh-mode))

; C
(setq-default c-basic-offset 4 c-default-style "linux")

(flycheck-mode t)
(cua-selection-mode t)

; Python
(add-hook 'python-mode-common-hook
          '(lambda () (flycheck-mode t)))

; Rust
(add-hook 'rust-mode-common-hook
          '(lambda () (flycheck-mode t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; General
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
  '(electric-indent-mode t)
  '(electric-pair-mode t)
  '(electric-layout-mode t))

(custom-set-variables
  '(line-number-mode t)
  '(column-number-mode t)
  '(visible-bell 'top-bottom)
  '(indent-tabs-mode nil))      ; never use tabs for spacing

; turn on pending delete (when a region is selected, typing replaces it)
(delete-selection-mode t)

; when on a tab, make the cursor the tab length
(setq-default x-stretch-cursor t)

; turn off stupid "yes" / "no" full word prompts
(fset 'yes-or-no-p 'y-or-n-p)

; use utf-8! details:
; http://www.masteringemacs.org/articles/2012/08/09/working-coding-systems-unicode-emacs/
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

; show the matching paren immediately, we are in a hurry
(setq show-paren-delay 0)
(show-paren-mode t)

; allow narrowing
(put 'narrow-to-region 'disabled nil)

;; this is suspend-frame by default, ie minimize the window if graphical
(global-unset-key [(control z)])

(start-shells)
<<<<<<< HEAD
=======




































(put 'erase-buffer 'disabled nil)
>>>>>>> 2e2fad3bda6deae102c81db421148e4195fe56af
