;; Put your customizations here.

;; Set ob-ipython tmp folder
(setq ob-ipython-resources-dir "/tmp/obipy-resources/")

;; Squash startup errors
(setq ess-smart-S-assign-key ";")
(setq ess-S-assign nil)

;; Org mode stuff
(setq initial-major-mode 'org-mode)
(require 'org-tempo)
(require 'scimax-statistics)
(require 'ob-sas)
(use-package ox-twbs)
(use-package ox-pandoc)
(setq org-latex-prefer-user-labels t)
(setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f"))
(setq org-src-preserve-indentation nil 
      org-edit-src-content-indentation 0)

;; scimax default latex packages are weird, so overwrite
(setq org-latex-default-packages-alist
      '(("AUTO" "inputenc" t ("pdflatex"))
	("T1" "fontenc" t ("pdflatex"))
	("" "graphicx" t)
	("" "grffile" t)
	("" "longtable" nil)
	("" "wrapfig" nil)
	("" "rotating" nil)
	("normalem" "ulem" t)
	("" "amsmath" t)
	("" "textcomp" t)
	("" "amssymb" t)
	("" "capt-of" nil)
	("" "hyperref" nil)
	;; mine below
	("all" "nowidow" nil)
	("" "booktabs" nil)
	("" "float" nil)
	("font=footnotesize" "subcaption" nil)
	("" "longtable" nil)
	("" "widetable" nil)
	("" "pdflscape" nil)
	("" "natbib" nil)
	("" "titlesec" nil)
	("" "titling" nil)
	("" "fancyhdr" nil)
	("hang,flushmargin" "footmisc" nil)
	))

;; TRAMP cache password
(setq password-cache-expiry nil)
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)

;; Replace default ESS SAS command with iESS
(defun SAS ()
  "Call 'SAS', from SAS Institute."
  (ess-sas-interactive))
;; (setq-default ess-sas-submit-command-options "-nodms -rsasuser -noovp -nosyntaxcheck -nonews")

(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)

(defun ess-eval-region-or-line-invisibly-and-step ()
  "Evaluate region if active, otherwise the current line and step.
Evaluation is done invisibly.
Note that when inside a package and namespaced evaluation is in
place (see `ess-r-set-evaluation-env') evaluation of multiline
input will fail."
  (interactive)
  (if (and transient-mark-mode mark-active)
      (call-interactively 'ess-eval-region)
    (call-interactively 'ess-eval-line-and-step)))

;; Re-bind C-c
(eval-after-load "ess-mode"
  '(progn
     (define-key ess-mode-map (kbd "C-c C-c") 'ess-eval-region-or-line-invisibly-and-step)
     ))

(setq org-image-actual-width 800)

(use-package writeroom-mode)

;; Bindings

;; Unbind Pesky Sleep Button
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-x C-z"))

;; Write over selections (including paste)
(delete-selection-mode 1)

;; Use Helm mini for buffers and Helm find
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)

;; Use Helm kill ring
(global-set-key (kbd "M-y") 'helm-show-kill-ring)

;; Mac keys
;; bind SUPER to ALT
(setq mac-option-modifier 'super)
;; bind META to CMD
(setq mac-command-modifier 'meta)
;; bind HYPER to FN
(setq mac-function-modifier 'hyper)
;; unbind right ALT for accents
(setq mac-right-option-modifier 'none)

;; Windmove
(global-set-key (kbd "H-<left>")  'windmove-left)
(global-set-key (kbd "H-<right>") 'windmove-right)

;; Pageup/Pagedown are reversed
(global-set-key (kbd "H-<down>") 'scroll-up)
(global-set-key (kbd "H-<up>")   'scroll-down)

;; Next buffer
(global-set-key (kbd "C-x <left>")  'previous-buffer)
(global-set-key (kbd "C-x <right>") 'next-buffer)

;; unfill region
(defun unfill-region (beg end)
  "Unfill the region, joining text paragraphs into a single
    logical line.  This is useful, e.g., for use with
    `visual-line-mode'."
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))

(define-key global-map "\C-\M-Q" 'unfill-region)

(defun org-edit-src-code (&optional code edit-buffer-name)
  "Got it work with :dir"
  (interactive)
  (let* ((element (org-element-at-point))
	 (type (org-element-type element)))
    (unless (and (memq type '(example-block src-block))
		 (org-src--on-datum-p element))
      (user-error "Not in a source or example block"))
    (let* ((lang
	    (if (eq type 'src-block) (org-element-property :language element)
              "example"))
	   (lang-f (and (eq type 'src-block) (org-src--get-lang-mode lang)))
	   (babel-info (and (eq type 'src-block)
			    (org-babel-get-src-block-info 'light)))
	   deactivate-mark)
      (when (and (eq type 'src-block) (not (functionp lang-f)))
	(error "No such language mode: %s" lang-f))
      (org-src--edit-element
       element
       (or edit-buffer-name
	   (org-src--construct-edit-buffer-name (buffer-name) lang))
       lang-f
       (and (null code)
	    (lambda () (org-escape-code-in-region (point-min) (point-max))))
       (and code (org-unescape-code-in-string code)))
      ;; Finalize buffer.
      (setq-local org-coderef-label-format
		  (or (org-element-property :label-fmt element)
		      org-coderef-label-format))
      (when (eq type 'src-block)
	(setq-local org-src--babel-info babel-info)
	;; hack start
	(when-let ((params (nth 2 babel-info))
		   (dir (alist-get :dir params)))
	  (cd (file-name-as-directory (expand-file-name dir))))
	;; hack end
	(let ((edit-prep-func (intern (concat "org-babel-edit-prep:" lang))))
	  (when (fboundp edit-prep-func)
	    (funcall edit-prep-func babel-info))))
      t)))

;; debug
;; (setq debug-on-error t)
