<?php

// adapted from https://github.com/dapphp/securimage/blob/master/example_form.php
// session_start MUST be called prior to any output including whitespaces and line breaks

error_reporting(E_ALL);
ini_set('display_errors', 1);
session_start();

?>

<!DOCTYPE html>
<html>
<head>

  <title>The Parri Ward</title>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <link rel="stylesheet" href="/securimage/securimage.css" media="screen">
  <link rel="stylesheet" href="/assets/css/main.css" />
  <style type="text/css">
  <!--
    body { font-family: 'Helvetica', 'Arial', sans-serif; }
    div.error { display: block; font-weight: bold; font-size: 1.2em; text-align:center; }
    span.error { display: block; font-style: italic; text-align:center; }
    .success {font-weight: bold; font-size: 1.2em; text-align:center; }
    form label { display: block; font-weight: bold; }
    fieldset { width: 70%; margin:auto; }
    .note { font-size: 18px;
  -->
  </style>
  <noscript><link rel="stylesheet" href="/assets/css/noscript.css" /></noscript>
</head>

<body class="is-preload">

  <div id="wrapper" class="divided">

    <!-- One -->
    <section class="banner style1 orient-left content-align-left image-position-right fullscreen onload-image-fade-in onload-content-fade-right">
      <div class="content">

        <?php
        process_si_verify_form();

        /* if the form submission had errors... */
        if (isset($_SESSION['ctform']['error']) &&  $_SESSION['ctform']['error'] == true): ?>
          <div class="error">The text did not match. Please try again.<br /></div>
        <?php endif; ?>

        <?php if (isset($_SESSION['ctform']['success']) && $_SESSION['ctform']['success'] == true):     /* humanity verified, reveal the goods */ ?>

            <h1>Join us.</h1>
            <p class="major">Welcome to ACME.</p>
            <ul class="actions stacked">
              <li><a href="#one" class="button big wide smooth-scroll-middle">Department one</a></li>
              <li><a href="#two" class="button big wide smooth-scroll-middle">Department two</a></li>
              <li><a href="#three" class="button big wide smooth-scroll-middle">Department three</a></li>
              <li><a href="#four" class="button big wide smooth-scroll-middle">Department four</a></li>
            </ul>

        <?php else: /* only show CAPTCHA if not already verified (error or first time here) */ ?>
          <fieldset>
            <div class="error">Help us stay secure by retyping the text from the picture.<br /></div>
            <form method="post" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI'] . $_SERVER['QUERY_STRING']) ?>" id="verify_form">

              <input type="hidden" name="do" value="verifyhumanity">

              <div>
                <?php
                  // display CAPTCHA form
                  require_once 'securimage/securimage.php';
                  $options = array();
                  $options['input_name']             = 'ct_captcha'; // change name of input element for form post
                  $options['disable_flash_fallback'] = true;         // don't allow flash fallback
                  if (!empty($_SESSION['ctform']['captcha_error'])) {
                    // error html to show in captcha output
                    $options['error_html'] = $_SESSION['ctform']['captcha_error'];
                  }
                  echo "<div id='captcha_container_1'>\n";
                  echo Securimage::getCaptchaHtml($options);
                  echo "\n</div>\n";
                ?>
              </div>

              <p>
                <input type="submit" value="I am not a robot">
              </p>

            </form>
          </fieldset>

        <?php endif; /* end if block to display captcha */ ?>

      </div> <!-- content -->

      <div class="image">
        <img src="images/banner.jpg" alt="" />
      </div>

    </section> <!-- One -->

    <!-- Footer -->
    <footer class="wrapper style1 align-center">
      <div class="inner">
        <p>site template: <a href="https://html5up.net">HTML5 UP</a>.</p>
      </div>
    </footer>

  </div> <!-- wrapper divided -->

  <script src="assets/js/jquery.min.js"></script>
  <script src="assets/js/jquery.scrollex.min.js"></script>
  <script src="assets/js/jquery.scrolly.min.js"></script>
  <script src="assets/js/browser.min.js"></script>
  <script src="assets/js/breakpoints.min.js"></script>
  <script src="assets/js/util.js"></script>
  <script src="assets/js/main.js"></script>

</body>
</html>

<?php

/* process CAPTCHA form */
function process_si_verify_form() {

  // re-initialize the form session data
  $_SESSION['ctform'] = array();

  // if the form has been submitted...
  if ($_SERVER['REQUEST_METHOD'] == 'POST' && @$_POST['do'] == 'verifyhumanity') {

    // sanitize the input data
    foreach($_POST as $key => $value) {
      if (!is_array($key)) {
        $_POST[$key] = htmlspecialchars(stripslashes(trim($value)));
      }
    }

    // the user's entry for the captcha code
    $captcha = @$_POST['ct_captcha'];

    // initialize empty error array
    $errors = array();

    // You could set some errors here ($errors['foo'] = 'bar';)

    // Only try to validate the CAPTCHA if the form has no errors
    if (sizeof($errors) == 0) {

      // validate CAPTCHA
      require_once dirname(__FILE__) . '/securimage/securimage.php';
      $securimage = new Securimage();
      if ($securimage->check($captcha) == false) {
        $errors['captcha_error'] = 'Incorrect CAPTCHA<br />';
      }

    }

    if (sizeof($errors) == 0) {
      // no form errors and CAPTCHA validated
      $_SESSION['ctform']['timetosolve'] = $securimage->getTimeToSolve();
      $_SESSION['ctform']['error'] = false;
      $_SESSION['ctform']['success'] = true;

    } else {
      // here you could repopulate the form with error messages
      // set error flag
      $_SESSION['ctform']['error'] = true;
    } // $errors check

  } // REQUEST_METHOD == POST
} // process_si_verify_form

// clear success value after once
$_SESSION['ctform']['success'] = false;
