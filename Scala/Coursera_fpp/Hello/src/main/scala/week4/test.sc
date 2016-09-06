// Base class for expression
trait Expr {
  def eval: Int
  def show: String
}

class Number(n: Int) extends Expr {
  def eval: Int = n
  def show: String = n.toString()
}

class Sum(e1: Expr, e2: Expr) extends Expr {
  def eval: Int = e1.eval + e2.eval
  def show: String = e1.show.concat("+").concat(e2.show)
}

val test = new Sum(new Number(1), new Number(2))
test.show
