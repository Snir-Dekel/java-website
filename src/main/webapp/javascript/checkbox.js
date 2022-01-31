$( document ).ready(function() {


           document.querySelector("#checkbox1_div > div > div > span").addEventListener(
          "mouseover",
          function() {
            document.querySelector(
                "#checkbox1_div > div > div > label.btn.btn-outline-danger.toggle-off").style.color = "white"
            document.querySelector(
                "#checkbox1_div > div > div > label.btn.btn-outline-success.toggle-on").style.color = "white"

          },
          false,
      )
      document.querySelector("#checkbox1_div > div > div > span").addEventListener(
          "mouseout",
          function() {
            document.querySelector(
                "#checkbox1_div > div > div > label.btn.btn-outline-danger.toggle-off").style.color = ""
            document.querySelector(
                "#checkbox1_div > div > div > label.btn.btn-outline-success.toggle-on").style.color = ""

          },
          false,
      )


document.querySelector("#checkbox2_div > div > div > span").addEventListener(
          "mouseover",
          function() {
            document.querySelector(
                "#checkbox2_div > div > div > label.btn.btn-outline-danger.toggle-off").style.color = "white"
            document.querySelector(
                "#checkbox2_div > div > div > label.btn.btn-outline-success.toggle-on").style.color = "white"

          },
          false,
      )
      document.querySelector("#checkbox2_div > div > div > span").addEventListener(
          "mouseout",
          function() {
            document.querySelector(
                "#checkbox2_div > div > div > label.btn.btn-outline-danger.toggle-off").style.color = ""
            document.querySelector(
                "#checkbox2_div > div > div > label.btn.btn-outline-success.toggle-on").style.color = ""

          },
          false,
      )
});