;; -*- lexical-binding: t;-*-

(when (< emacs-major-version 30)
  (error "Hey, so, this wont work, use emacs version 30 or higher"))

(setq custom-file "~/.emacs.custom.el")

(when (eq system-type 'darwin)
  (let ((path (format "%s:%s" (getenv "PATH") "/opt/homebrew/bin")))
    (setenv "PATH" path)))


(progn
  (unless (package-installed-p 'use-package) (package-refresh-contents) (package-install 'use-package))
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (package-refresh-contents))

(defmacro use-key (key cmd) `(global-set-key (kbd ,key) ,cmd))
(defmacro neq (lhs rhs) `(not (eq ,lhs ,rhs)))

(use-package catppuccin-theme :ensure
  :init
  (setq should-use-transparency t)
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin :no-confirm)
  :config
  (toggle-frame-maximized)
  (when should-use-transparency
    (catppuccin-set-color 'base "#323232")
    (set-frame-parameter nil 'alpha '(69 69))
    (catppuccin-reload)))

(use-package emacs :ensure
  :config
  (set-frame-font "Hack-18" nil t)

  (defun emacs/emacs-scroll-down () (interactive) (next-line 6))
  (defun emacs/emacs-scroll-up () (interactive) (previous-line 6))
  (defun emacs/snippet () (interactive))
  (defun emacs/kill-all-buffers () (interactive)
    (mapcar 'kill-buffer (buffer-list)))

  (setq emacs/setting-macro-status nil)
  (defun emacs/macro-start-end ()
    (interactive)
    (if (not emacs/setting-macro-status)
      (progn
        (setq emacs/setting-macro-status t)
        (call-interactively 'kmacro-start-macro))
      (progn
        (setq emacs/setting-macro-status nil)
        (call-interactively 'kmacro-end-macro))))

  (defun docket ()
    "Jump to our default org file"
    (interactive)
    (find-file (format "%s%s" (getenv "HOME") "/.emacs.d/org/docket.org")))

  (defun org ()
    "Jump to the org folder"
    (find-file (format "%s%s" (getenv "HOME") "/.emacs.d/org/")))

  (defun config ()
    "Jump to this file!"
    (interactive)
    (find-file (format "%s%s" (getenv "HOME") "/.emacs")))

  (defun project-switch-to-project ()
    (interactive)
    (setq project-switch-commands 'find-file-rg)
    (call-interactively 'project-switch-project))

  (use-key "C-x f" 'find-file)
  (use-key "C-x r" 'grep)
  (use-key "C-x C-r" 'project-find-regexp)
  (use-key "C-x C-p" 'project-switch-to-project)
  (use-key "C-M-c" 'mc/mark-next-like-this)
  (use-key "C-M-i" 'xref-find-definitions)
  (use-key "C-v" 'emacs/emacs-scroll-down)
  (use-key "M-v" 'emacs/emacs-scroll-up)
  (use-key "s-n" 'eldoc-doc-buffer)
  (use-key "M-z" 'emacs/snippet)
  (use-key "C-x C-b" 'emacs/kill-all-buffers)
  (use-key "M-q" 'emacs/macro-start-end)
  (use-key "M-@" 'kmacro-call-macro)
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

  (progn
    (setq treesit-language-source-alist '())
    (defmacro use-grammar (file-type url &optional branch folder) `(add-to-list 'treesit-language-source-alist '(,file-type ,url ,branch ,folder)))
    (use-grammar c "https://github.com/tree-sitter/tree-sitter-c")
    (use-grammar cpp "https://github.com/tree-sitter/tree-sitter-cpp")
    (use-grammar cmake "https://github.com/uyha/tree-sitter-cmake")
    (use-grammar elisp "https://github.com/Wilfred/tree-sitter-elisp")
    (use-grammar make "https://github.com/alemuller/tree-sitter-make")
    (use-grammar bash "https://github.com/tree-sitter/tree-sitter-bash")
    (use-grammar markdown "https://github.com/ikatyang/tree-sitter-markdown")
    (use-grammar html "https://github.com/tree-sitter/tree-sitter-html")
    (use-grammar nix "https://github.com/nix-community/tree-sitter-nix")
    (use-grammar css "https://github.com/tree-sitter/tree-sitter-css")
    (use-grammar typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
    (use-grammar javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
    (use-grammar json "https://github.com/tree-sitter/tree-sitter-json")
    (use-grammar ruby "https://github.com/tree-sitter/tree-sitter-ruby")
    (use-grammar go "https://github.com/tree-sitter/tree-sitter-go")
    (use-grammar python "https://github.com/tree-sitter/tree-sitter-python")
    (use-grammar toml "https://github.com/tree-sitter/tree-sitter-toml")
    (use-grammar tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
    (use-grammar yaml "https://github.com/ikatyang/tree-sitter-yaml")
    (use-grammar gd "https://github.com/PrestonKnopp/tree-sitter-gdscript.git")
    (add-hook 'c-mode-hook 'c-ts-mode)))

(use-package magit :ensure
  :config
  (defun magit-show ()
    "Show the file changes by commit"
    (interactive)
    (magit-log-buffer-file))

  (defun magit-copy-branch-name ()
    "copy the current branch name to the system clipboard"
    (interactive)
    (if (magit-get-current-branch)
      (progn
        (kill-new (magit-get-current-branch))
        (message "%s" (magit-get-current-branch)))
      (user-error "No Current branch!!"))))

(use-package vertico :ensure :config
  (setopt
   vertico-mode t
   vertico-mouse-mode t
   vertico-cycle t))

(use-package orderless :ensure :config
  (setopt
   completion-styles '(orderless basic)
   completion-category-overrides '((file (styles partial-completion)))))

(use-package find-file-rg :ensure :config
  (use-key "C-x C-f" 'find-file-rg))

(use-package multiple-cursors :ensure :config
  (define-key mc/keymap (kbd "<return>") nil)
  (use-key "C-M-c" 'mc/mark-next-like-this))

(use-package eglot :ensure :config
  (use-key "M-n" 'eglot-code-actions)
  (use-key "C-x C-q" 'eglot-format-buffer))

(use-package go-mode :ensure)
(use-package lua-mode :ensure :mode "\\.lua$")
(use-package typescript-ts-mode :ensure :mode "\\.ts[x]*$")
(use-package gdscript-mode :ensure :mode "\\.gd$"
  :hook (gdscript-mode . eglot-ensure)
  :custom (gdscript-eglot-version 3))

(use-package corfu :ensure :config
  (setopt
   corfu-auto t
   corfu-auto-delay 0.1
   corfy-cycle t)
  :init
  (global-corfu-mode))

(use-package org :ensure
  :config
  (use-package org-roam :ensure
    :init
    (defmacro mkdir-a (directory)
      `(unless (file-directory-p ,directory)
         (make-directory ,directory)))
    (setq org-directory        (format "%s/.emacs.d/org" (getenv "HOME")))
    (setq org-roam-directory   (format "%s" org-directory))
    (setq org-agenda-directory (format "%s" org-directory))
    (mkdir-a org-directory)
    (mkdir-a org-roam-directory)
    (mkdir-a org-agenda-directory)
    (setq org-agenda-files (list org-agenda-directory))

    :config
    (org-roam-db-autosync-mode)
    (setopt
      org-hide-emphasis-markers t
      org-hide-leading-stars t
      org-list-allow-alphabetical t)
    (use-key "C-c a" 'org-agenda)))

(load custom-file)
