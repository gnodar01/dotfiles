;; In ~/.emacs: (load (concat (getenv "HOME") "/superhome/config/emacs.init.el"))

(setq user-emacs-directory (concat (getenv "HOME") "/superhome/config/.emacs.d"))
;; elpa is already the default, just changing it to point at superhome
;; otherwise it will use ~/.emacs.d
(setq package-user-dir (concat (getenv "HOME") "/superhome/config/.emacs.d/elpa"))


;; initialize package sources
;; probably auto-loaded, but whatever
(require 'package)

;; package list, all the package repos we're pulling from
(setq package-archives
  '(("melpa" . "https://melpa.org/packages/")
    ;;("melpa" . "https://stable.melpa.org/packages/")
    ("org" . "https://orgmode.org/elpa/")
    ("gnu" . "https://elpa.gnu.org/packages/")))

;; booststrap
(package-initialize)

;; on very first load, see if package archive on computer, else load it
(unless package-archive-contents
  (package-refresh-contents))

;; initialize use-package
;; generally, functions ending in -p are predicates, return true or nil
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))

(setq use-package-always-ensure t)

(use-package evil
  :demand t
  ;; esc to get out prompts and the like
  :bind (("<escape>" . keyboard-escape-quit))
  :init
  ;; allows for using cgn
  ;; (setq evil-search-module 'evil-search)
  (setq evil-want-keybinding nil)
  ;; no vim insert bindings
  :config
  (evil-mode 1))

;; vim bindings everywhere else
(use-package evil-collection
  :after evil
  :config
  (setq evil-want-integration t)
  (evil-collection-init))
(evil-set-undo-system 'undo-redo)

(use-package org)
;; this lets us do <s TAB and the like in org mode
;; it was disabled in later versions of org-mode in favor of
;; "C-c C-," which is structured templates
;; but "C-," hard to do in terminal, need "C-x @ c ," instead
(require 'org-tempo)


;; Change to the path where you cloned the config to
;;(org-babel-load-file (concat (getenv "HOME") "/superhome/config/.emacs.d/myinit.org"))
(org-babel-load-file (expand-file-name "myinit.org" user-emacs-directory))

