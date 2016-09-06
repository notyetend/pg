name := "sparkpj"

version := "1.0"

scalaVersion := "2.11.8"


libraryDependencies ++= Seq(
  // Spark dependency
  "org.apache.spark" % "spark-core_2.10" % "1.2.0" % "provided",
  // Third-party libraries
  "net.sf.jopt-simple" % "jopt-simple" % "4.3",
  "joda-time" % "joda-time" % "2.0"
)
