;; Richard and Tim's time tracker
;;===========================================
;; Version History
;;===========================================
;; v0.99 - Alpha (development) -- 2010-APR-19
;; First version ready to go for testing.
;;===========================================
(define-minor-mode rattt-mode
  "Richard and Tim's Time Tracker mode.
     The most awesome time tracker ever.
     
     When Rattt mode is enabled: 
     C-M-t creates a new task.
     See the command \\[rattt-task-new]
     
     C-M-e closes a task.
     See the command \\[rattt-task-end]

     C-M-c toggles the 'complete' value of an item. Works on TODO items and
     Time Entry items.
     See the command \\[rattt-set-item-complete]"
  ;; The initial value.
  nil
  ;; The indicator for the mode line.
  " rattt"
  ;; The minor mode bindings.
  '(("\C-\M-t" . rattt-task-new)
    ("\C-\M-e" . rattt-task-end)
    ("\C-\M-c" . rattt-set-item-complete)
    ("\C-\M-r" . rattt-todo-new))
  :group 'rattt)

(defvar *task-history* nil)
(defvar *todo-history* nil)

(defun rattt-task-new (str)
  "Add a new task."
  (interactive 
   (list 
    (read-from-minibuffer "Input task: " 
                          (car *task-history*) 
                          nil nil '*task-history*)))
  (goto-char (point-min))  

  (if (equal (search-forward "+----" nil t) nil) (insert "+----\n----+"))
  (rattt-find-last-time-entry)
  (insert "[ ]  " str " (" (format-time-string "%R" (current-time)) " - )\n")
  (backward-char))

(defun rattt-task-end ()
  "End a task."
  (interactive)
  (save-excursion
    (move-end-of-line nil)
    (backward-char)
    (insert (format-time-string "%R" (current-time)))
    (move-end-of-line nil)))
    ;; not implemented yet
    ;;(insert "  [" (rattt-find-time-to-eval) "]")))

(defun rattt-find-time-to-eval ()
  (interactive)
  (move-beginning-of-line nil)
  (list
   (re-search-forward "(.*?)")
   (setq my-start-time (match-beginning 0))
   (setq my-end-time (match-end 0))
   (setq my-time-range (buffer-substring my-start-time my-end-time))
   (print my-time-range)
   (let* ((time-span my-time-range)
          (split-time-list (split-string (substring time-span 1 (1- (length time-span))) " - "))
          (first-time nil)
          (second-time nil))
     (setq first-time (car split-time-list))
     (setq second-time (cadr split-time-list))                          
     (print first-time)
     (print second-time)))
  (number-to-string 123))

(defun rattt-time-span ()
  (insert "Not Implemented")
  )
(defun rattt-find-last-time-entry ()
  (goto-char (point-min))
  (search-forward "----+")
  (move-beginning-of-line nil))

(defun rattt-create-new-daily-template ()
  (interactive)
  (goto-char (point-min))  
  (insert (format-time-string "%A %Y-%b-%d" (current-time)) "\n\nTODO:\n\nNOTES:\n\nTIME ENTRIES:\n+----\n----+\n\n"))

(defun rattt-todo-new (str)
  "Add a new TODO item to current day"
  (interactive 
   (list 
    (read-from-minibuffer "Input TODO item: " 
                          (car *todo-history*) 
                          nil nil '*todo-history*)))
  (goto-char (point-min))  

  (search-forward "TODO:" nil t)
  (newline)
  (insert "[ ]  " str))

(defun rattt-set-item-complete ()
  "Toggles the completed value of TODO items and Time Entry items."
  (interactive)
  (save-excursion
    (move-beginning-of-line nil)
    (if (equal (char-after (1+ (point))) (string-to-char "X"))
        (rattt-complete-toggle " ")
      (rattt-complete-toggle "X"))))

(defun rattt-complete-toggle (chr)
  "When cursor is placed on any TODO item or Time Entry item, it will check to see if task has been
completed. If not, it will place an 'X' in the checkbox. If the task had already been
completed, the 'X' will be removed from the checkbox."
  (move-beginning-of-line nil)
  (forward-char)
  (delete-char 1)
  (insert chr))

;;(global-set-key (kbd "C-x C-M-t") 'rattt-task-new)
;;(global-set-key (kbd "C-x C-M-e") 'rattt-task-end)
