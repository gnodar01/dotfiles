;; get rid of startup message
;; just starts scratch buffer if no file
(setq inhibit-startup-message t)
(scroll-bar-mode -1) ; Disable gui's visible scroll bar
(tool-bar-mode -1)   ; Disable gui's toolbar (where the icons are)
(tooltip-mode -1)    ; Disable gui's hover tooltips
(menu-bar-mode -1)   ; Disable both's menu bar (file, edit, etc)

;; : describe-function load-theme
;;(load-theme 'tango-dark)

;; see function names assigned to keys as you press them
;; to use:
;; :global-command-line-buffer
;; :clm/toggle-command-line-buffer
(use-package command-log-mode)

;; helm and ivy are the main two completion frameworks
