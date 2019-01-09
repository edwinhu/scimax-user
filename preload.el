;; git id
(defvar kitchingroup-github-id 'jkitchin)

;; PATHs
(setenv "PATH" (concat "~/anaconda3/bin:" "/usr/local/bin:" (getenv "PATH")))
(setq exec-path (append '("~/anaconda3/bin" "/usr/local/bin") exec-path))
