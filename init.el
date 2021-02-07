;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; this is to support loading from a non-standard .emacs.d
;; via emacs -q --load "/path/to/init.el"
;; see https://emacs.stackexchange.com/a/4258/22184
(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

(require 'package)
(add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(load-theme 'leuven t)
(fset 'yes-or-no-p 'y-or-n-p)
(recentf-mode 1)
(setq recentf-max-saved-items 100)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

(cond
 ((member "Monaco" (font-family-list))
  (set-face-attribute 'default nil :font "Monaco-12"))
 ((member "Inconsolata" (font-family-list))
  (set-face-attribute 'default nil :font "Inconsolata-12"))
 ((member "Consolas" (font-family-list))
  (set-face-attribute 'default nil :font "Consolas-11"))
 ((member "DejaVu Sans Mono" (font-family-list))
  (set-face-attribute 'default nil :font "DejaVu Sans Mono-10")))

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; Rust config starts here

(use-package lsp-mode
  :ensure
  :commands lsp
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  ;; (setq lsp-rust-server 'rust-analyzer)
  )

(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil)
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6))


(defun company-yasnippet-or-completion ()
  (interactive)
  (or (do-yas-expand)
      (company-complete-common)))

(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "::") t nil)))))

(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

(defun tab-indent-or-complete ()
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (if (or (not yas/minor-mode)
            (null (do-yas-expand)))
        (if (check-expansion)
            (company-complete-common)
          (indent-for-tab-command)))))

(use-package company
  :ensure
  :bind
  (:map company-active-map
	      ("C-n". company-select-next)
	      ("C-p". company-select-previous)
	      ("M-<". company-select-first)
	      ("M->". company-select-last)
	      ;;("<tab>". company-yasnippet-or-completion)
	      ;; ("TAB". company-yasnippet-or-completion)
	      )
  (:map company-mode-map
	("<tab>". tab-indent-or-complete)
	("TAB". tab-indent-or-complete)))

(use-package company-lsp
  :ensure
  :commands company-lsp
  :config (push 'company-lsp company-backends))

(use-package flycheck :ensure)

(use-package flycheck-rust :ensure)

;; (use-package rust-mode :ensure
;;   :config
;;   (add-hook 'rust-mode-hook 'lsp)
;;   (add-hook 'rust-mode-hook 'company-mode)
;;   (add-hook 'flycheck-mode-hook 'flycheck-rust-setup))


;; lsp-rust-analyzer-call-info-full
;; lsp-rust-show-hover-context
;; (setq lsp-signature-auto-activate nil)
;;   (setq lsp-enable-symbol-highlighting nil)
;;   (setq lsp-eldoc-hook nil)


(use-package rustic
    :ensure
    ;; :custom
    ;; (rustic-test-arguments "--nocapture")
    ;; (rustic-format-on-save nil)
    ;; (rustic-lsp-format t)
    ;; (lsp-rust-full-docs t)
    ;; (lsp-rust-analyzer-cargo-watch-command "clippy")

    :bind (:map rustic-mode-map
                ("M-?" . lsp-find-references)
		("C-c C-c a" . lsp-execute-code-action)
		("C-c C-c r" . lsp-rename)
		("C-c C-c q" . lsp-workspace-restart)
		("C-c C-c Q" . lsp-workspace-shutdown)
		("C-c C-c s" . lsp-rust-analyzer-status))

    ;; :config
    ;; (add-hook 'rustic-mode-hook 'company-mode)
    )

(use-package yasnippet
  :ensure
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode))

(use-package which-key
  :ensure
  :init
  (which-key-mode))

(use-package selectrum
  :ensure
  :init
  (selectrum-mode)
  :custom
  (completion-styles '(flex substring partial-completion)))

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;; (defun rk/define-prefix-command-map (prefix-symbol parent-map kbd-in-parent key-map)
;;   ""
;;   (let ((map (define-prefix-command prefix-symbol)))
;;     (define-key parent-map kbd-in-parent map)
;;     (cl-loop for (key . sym) in key-map
;; 	     do (define-key map key sym))))

;; (global-set-key (kbd "M-m") 'company-complete)
;; (define-key global-map (kbd "C-c f") flycheck-command-map)

;; ;; (define-key rustic-mode-map (kbd "C-c C-c") 'rust-run)

;; (rk/define-prefix-command-map
;;       'rk/rust-lsp-prefix-map rust-mode-map (kbd "C-c r")
;;       '(("a" . lsp-execute-code-action)
;;         ("r" . lsp-rename)
;;         ("q" . lsp-workspace-restart)
;;         ("Q" . lsp-workspace-shutdown)
;;         ("i" . lsp-rust-analyzer-status)))
