package br.gsj.besouro.rl

import scala.util.Random

object Training {
  
  private val length_buttons = 12;
  
  def sort_command(): Int ={
    Random.nextInt(length_buttons)
  }

  
}