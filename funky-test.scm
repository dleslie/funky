(use funky)

(define (script-method)
  (with-funky booyah
   (display "Sure\n")
   (display "Whatever\n")))

(booyah-library-method)

(define-funky not-funky "If you could read my mind love What a tale my thoughts could tell Just like an old time movie About a ghost from a wishin' well ")

(with-funky not-funky
 (display "...\n"))
