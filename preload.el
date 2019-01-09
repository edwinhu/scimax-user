;; git id
(defvar kitchingroup-github-id 'edwinhu)

;; PATHs
(setenv "PATH" (concat "$HOME/anaconda3/bin:" "/usr/local/bin:" (getenv "PATH")))
(setq exec-path (append '("$HOME/anaconda3/bin" "/usr/local/bin") exec-path))
