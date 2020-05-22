;;; org-note.el --- a moderate note-taking system -*- lexical-binding: t; -*-

;; Author: u2zv1wx <u2zv1wx@protonmail.ch>
;; Version: 0.1

;;; Commentary:

;; With org-note you can:
;; - open/create a file for a day, inserting templates if necessary
;; - switch to the previous/next notepad

;;; Code:

(defgroup org-note nil
  "Settings for the moderate note-taking system"
  :version "0.1"
  :group 'applications)

;;;###autoload
(defcustom org-note-file-format "%Y-%m-%d.org"
  "The format of filenames to be created"
  :type 'string
  :group 'org-note)

;;;###autoload
(defcustom org-note-dir nil
  "Where to create notepads"
  :type 'string
  :group 'org-note)

;;;###autoload
(defcustom org-note-header-format "* %Y-%m-%d"
  "The header string inserted to newly created files"
  :type 'string
  :group 'org-note)

;;;###autoload
(defcustom org-note-find-file 'find-file-other-window
  "The function to use when opening an entry."
  :type 'function
  :group 'org-note)

(defun org-note-get-entry-path ()
  "Return the path to an entry using the current time."
  (expand-file-name
   (format-time-string org-note-file-format)
   org-note-dir))

(defun org-note-ensure-dir ()
  (when (null org-note-dir)
    (error "You need to specify where to save notes with org-note-dir.")))

(defun org-note-dir-check-or-create ()
  "Check existence of `org-note-dir'. If it doesn't exist, try to make directory."
  (unless (file-exists-p org-note-dir)
    (if (yes-or-no-p (format "Directory %s not found. Create one? " org-note-dir))
        (make-directory org-note-dir t)
      (error "Note directory is necessary to use org-note."))))

;;;###autoload
(defun org-note-new-entry ()
  "Open today's note file and start a new entry."
  (interactive)
  (org-note-ensure-dir)
  (org-note-dir-check-or-create)
  (let* ((entry-path (org-note-get-entry-path)))
    (unless (string= entry-path (buffer-file-name))
      (funcall org-note-find-file entry-path))
    (when (equal (point-max) 1)
      (insert (format-time-string org-note-header-format)))))

;;;###autoload
(defun org-note-new-entry-in-current-buffer ()
  "Open today's note file and start a new entry."
  (interactive)
  (org-note-ensure-dir)
  (org-note-dir-check-or-create)
  (let* ((entry-path (org-note-get-entry-path)))
    (unless (string= entry-path (buffer-file-name))
      (find-file entry-path))
    (when (equal (point-max) 1)
      (insert (format-time-string org-note-header-format)))))

(defun org-note-open-next-entry ()
  "Open the next entry starting from a currently displayed one"
  (interactive)
  (let* ((f (file-name-nondirectory (buffer-file-name)))
         (fs (directory-files org-note-dir nil ".+\.org"))
         (i (cl-position f fs :test 'equal)))
    (if (< i (1- (length fs)))
        (find-file (expand-file-name (nth (1+ i) fs)))
      (message "No next entry after this one"))))

(defun org-note-open-previous-entry ()
  "Open the previous entry starting from a currently displayed one"
  (interactive)
  (let* ((f (file-name-nondirectory (buffer-file-name)))
         (fs (directory-files org-note-dir nil ".+\.org"))
         (i (cl-position f fs :test 'equal)))
    (if (> i 0)
        (find-file (expand-file-name (nth (1- i) fs)))
      (message "No previous entry before this one"))))

(provide 'org-note)
;;; org-note.el ends here
