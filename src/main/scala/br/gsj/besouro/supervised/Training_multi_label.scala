package br.gsj.besouro.supervised

import scala.collection.mutable.ListBuffer

import org.deeplearning4j.nn.conf.NeuralNetConfiguration
import org.deeplearning4j.nn.weights.WeightInit
import org.deeplearning4j.datasets.datavec.RecordReaderDataSetIterator;
import org.nd4j.linalg.learning.config.Nesterovs
import org.nd4j.linalg.learning.config.AdaGrad
import org.nd4j.linalg.activations.Activation
import org.deeplearning4j.nn.conf.layers.DenseLayer
import org.deeplearning4j.nn.conf.layers.OutputLayer
import org.deeplearning4j.nn.api.OptimizationAlgorithm
import org.nd4j.linalg.lossfunctions.LossFunctions
import org.datavec.api.records.reader.impl.csv.CSVRecordReader
import org.datavec.api.split.FileSplit
import java.io.File
import org.nd4j.linalg.factory.Nd4j
import java.io.BufferedReader
import java.io.FileReader
import org.nd4j.linalg.dataset.DataSet
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.nd4j.evaluation.classification.Evaluation
import org.deeplearning4j.nn.conf.distribution.UniformDistribution
import org.nd4j.linalg.learning.config._
import org.nd4j.linalg.lossfunctions.impl.LossMultiLabel
import org.deeplearning4j.optimize.listeners.ScoreIterationListener
import org.deeplearning4j.nn.conf.layers.ConvolutionLayer;
import org.deeplearning4j.nn.conf.graph.MergeVertex;
import org.deeplearning4j.nn.conf.layers.GlobalPoolingLayer
import org.deeplearning4j.nn.conf.inputs.InputType
import org.deeplearning4j.nn.conf.layers.PoolingType
import org.deeplearning4j.nn.graph.ComputationGraph

//import org.deeplearning4j.nn.conf.layers.

object Training_multi_label {

  def main(args: Array[String]): Unit = {
    val nEpochs = 5
    val seed = 1234
    val learningRate = 0.1

    val globalPoolingType = PoolingType.MAX;

    val data = loadTrainingInputData(new File("src/main/resources/training.data"))

    val input = Nd4j.createFromArray(data._1);
    val labels = Nd4j.createFromArray(data._2);

    val ds = new DataSet(input, labels);

    val configuration = new NeuralNetConfiguration.Builder()
      .seed(seed)
      .weightInit(WeightInit.RELU)
      .activation(Activation.LEAKYRELU)
      .optimizationAlgo(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT)
      //.updater(new Nesterovs(learningRate))
      .updater(new Adam(learningRate))
      .l2(0.0001)
      .graphBuilder()
      .addInputs("input")
      .addLayer("cnn3", new ConvolutionLayer.Builder()
        .kernelSize(3, 100)
        .stride(1, 10)
        .nOut(100)
        .build(), "input")
      .addLayer("cnn4", new ConvolutionLayer.Builder()
        .kernelSize(4, 100)
        .stride(1, 10)
        .nOut(100)
        .build(), "input")
      .addLayer("cnn5", new ConvolutionLayer.Builder()
        .kernelSize(5, 100)
        .stride(1, 10)
        .nOut(100)
        .build(), "input")
      .addVertex("merge", new MergeVertex(), "cnn3", "cnn4", "cnn5")

      .addLayer("globalPool", new GlobalPoolingLayer.Builder()
        .poolingType(globalPoolingType)
        .dropOut(0.5)
        .build(), "merge")
      .addLayer("out", new OutputLayer.Builder()
        .lossFunction(new LossMultiLabel())
        .activation(Activation.SIGMOID)
        .nOut(10) //number of intents/labels
        .build(), "globalPool")
      .setOutputs("out")
      //Input has shape [minibatch, channels=1, length=1 to 256, 300]
      .setInputTypes(InputType.convolutional(100, 100, 1))
      .build();

    val net = new ComputationGraph(configuration);
    net.init();
    net.setListeners(new ScoreIterationListener(100));

    println(net.summary())

    println(configuration.toJson())

    for (n <- 1 to nEpochs) {
      net.fit(ds);
      println("Epoch ... " + n)
    }
    // create output for every training sample
    val output = net.output(ds.getFeatures());
    //net.save(new File("src/main/resources/model.data"))

    println(output)
    /*
        // let Evaluation prints stats how often the right output had the highest value
        val eval = new Evaluation();
        eval.eval(ds.getLabels(), output);
        println(eval.stats());*/
  }

  def loadTrainingInputData(f: File): (Array[Array[Int]], Array[Array[Int]]) = {
    val br = new BufferedReader(new FileReader(f))
    var s = br.readLine()
    var inputs = ListBuffer[Array[Int]]()
    var labels = ListBuffer[Array[Int]]()

    while (s != null) {
      val l = s.split("\\|")
      val i_l = l(0).split(",").map(i => i.toInt)
      val l_l = l(1).split(",").map(l => l.toInt)

      inputs += i_l
      labels += l_l

      s = br.readLine()
    }

    /* inputs.foreach{f =>
      f.foreach(x => print(x + " ") )
      println()
  }*/

    return (inputs.toArray, labels.toArray)
  }

}