;;; Will's super simple pretty printer for miniKanren--designed for live coding
;;;
;;; Don't forget to load miniKanren first!

(define mkp
  (lambda (ls)
    (if (null? ls)
        (begin
          (write ls)
          (newline))
        (begin
          (newline)
          (display #\()
          (newline)
          (for-each (lambda (x) (write x) (newline)) ls)
          (display #\))
          (newline)))))

(define-syntax runp
  (syntax-rules ()
    [(_ exp (q) body body* ...)
     (mkp (run exp (q) body body* ...))]))

(define-syntax runp*
  (syntax-rules ()
    [(_ (q) body body* ...)
     (mkp (run* (q) body body* ...))]))

#!eof

;;; Example usage:

(define appendo
  (lambda (l s out)
    (conde
      ((== '() l) (== s out))
      ((fresh (a d res)
         (== `(,a . ,d) l)
         (== `(,a . ,res) out)
         (appendo d s res))))))


;;; Standard run returns a list of values, potentially ugly:
> (run 10 (q) (fresh (l s ls) (appendo l s ls) (== `(,l ,s ,ls) q)))
((() _.0 _.0) ((_.0) _.1 (_.0 . _.1)) ((_.0 _.1) _.2 (_.0 _.1 . _.2))
  ((_.0 _.1 _.2) _.3 (_.0 _.1 _.2 . _.3))
  ((_.0 _.1 _.2 _.3) _.4 (_.0 _.1 _.2 _.3 . _.4))
  ((_.0 _.1 _.2 _.3 _.4) _.5 (_.0 _.1 _.2 _.3 _.4 . _.5))
  ((_.0 _.1 _.2 _.3 _.4 _.5)
    _.6
    (_.0 _.1 _.2 _.3 _.4 _.5 . _.6))
  ((_.0 _.1 _.2 _.3 _.4 _.5 _.6)
    _.7
    (_.0 _.1 _.2 _.3 _.4 _.5 _.6 . _.7))
  ((_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7)
    _.8
    (_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7 . _.8))
  ((_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7 _.8)
    _.9
    (_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7 _.8 . _.9)))


;;; runp *prints* a list of answers
> (runp 10 (q) (fresh (l s ls) (appendo l s ls) (== `(,l ,s ,ls) q)))

(
(() _.0 _.0)
((_.0) _.1 (_.0 . _.1))
((_.0 _.1) _.2 (_.0 _.1 . _.2))
((_.0 _.1 _.2) _.3 (_.0 _.1 _.2 . _.3))
((_.0 _.1 _.2 _.3) _.4 (_.0 _.1 _.2 _.3 . _.4))
((_.0 _.1 _.2 _.3 _.4) _.5 (_.0 _.1 _.2 _.3 _.4 . _.5))
((_.0 _.1 _.2 _.3 _.4 _.5) _.6 (_.0 _.1 _.2 _.3 _.4 _.5 . _.6))
((_.0 _.1 _.2 _.3 _.4 _.5 _.6) _.7 (_.0 _.1 _.2 _.3 _.4 _.5 _.6 . _.7))
((_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7) _.8 (_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7 . _.8))
((_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7 _.8) _.9 (_.0 _.1 _.2 _.3 _.4 _.5 _.6 _.7 _.8 . _.9))
)


;;; as does runp*
> (runp* (q) (fresh (l s) (appendo l s '(a b c d e)) (== `(,l ,s) q)))

(
(() (a b c d e))
((a) (b c d e))
((a b) (c d e))
((a b c) (d e))
((a b c d) (e))
((a b c d e) ())
)


;;; If there are no answers, runp and runp* displays the empty list.
> (runp* (q) (appendo '(a) '(b) '(c)))
()
>


;;; Unlike run, runp and runp* return #<void>:
> (list 'value-returned (runp 1 (q) (fresh (l s ls) (appendo l s ls) (== `(,l ,s ,ls) q))))

(
(() _.0 _.0) ; pretty printed answer
)
(value-returned #<void>) ; unspecified value returned (#<void> in Chez Scheme)
