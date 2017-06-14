/**
  * Created by Bar on 2016-08-28.
  */
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.SparkContext._

object ScalaWordCount {
  def main(args: Array[String]) {

    val logFile = "hdfs://master.backtobazics.com:9000/user/root/sample.txt"
    val sparkConf = new SparkConf().setAppName("Spark Word Count")
    val sc = new SparkContext(sparkConf)
    val file = sc.textFile(logFile)
    val counts = file.flatMap(_.split(" ")).map(word => (word, 1)).reduceByKey(_ + _)
    counts.saveAsTextFile("hdfs://master.backtobazics.com:9000/user/root/output")
  }
}
