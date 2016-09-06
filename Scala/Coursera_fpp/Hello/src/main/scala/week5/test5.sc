val nums = List(2, -4, 5, 7, 1)

nums filter (x => x > 0)
nums filterNot (x => x > 0)
nums partition (x => x > 0)

nums takeWhile(x => x > 0)
nums dropWhile(x => x > 0)
nums span(x => x > 0)

val test = (1, 2)
nums.length

val data = List("a", "a", "a", "b", "c", "c", "a")
def pack[T](xs: List[T]): List[List[T]] = xs match {
  case Nil => Nil
  case x :: xs1 =>
    val (first, rest) = xs span (y => y ==x)
    first :: pack(rest)
}

pack(data)

def encode[T](xs: List[T]): List[(T, Int)] =
  pack(xs) map (ys => (ys.head, ys.length))


def sum(xs: List[Int]): (0 :: xs) reduceLeft (_ + _)

def product(xs: List[Int]): (0 :: xs) reduceLeft (_ * _)

