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
  <meta charset="utf-8">
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <link rel="stylesheet" href="/securimage/securimage.css" media="screen">
  <style type="text/css">
  <!--
  body { font-family: 'Helvetica', 'Arial', sans-serif; }
  div.error { display: block; color: #f00; font-weight: bold; font-size: 1.2em; text-align:center; }
  span.error { display: block; color: #f00; font-style: italic; text-align:center; }
  .success { color: #00f; font-weight: bold; font-size: 1.2em; text-align:center; }
  form label { display: block; font-weight: bold; }
  fieldset { width: 50%; margin:auto; }
  .note { font-size: 18px;
  -->
  </style>
</head>

<body>
<fieldset>

<?php
process_si_verify_form();
if (isset($_SESSION['ctform']['error']) &&  $_SESSION['ctform']['error'] == true):              /* form submission had errors */ ?>
<div class="error">Incorrect CAPTCHA, please try again.</div><br>
<?php endif; ?>

<?php if (isset($_SESSION['ctform']['success']) && $_SESSION['ctform']['success'] == true):     /* humanity verified, reveal the goods */ ?>

<div class="success">The CAPTCHA was solved in <?php echo $_SESSION['ctform']['timetosolve'] ?> seconds.</div><br />

<?php else: /* only show CAPTCHA if not already verified (error or first time here) */ ?>

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

<?php endif; /* end if block to display captcha */ ?>

</fieldset>
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
        $errors['captcha_error'] = 'Incorrect CAPTCHA, please try again.<br />';
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
