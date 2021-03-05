<?php

// adapted from https://github.com/dapphp/securimage/blob/master/example_form.php

error_reporting(E_ALL);
ini_set('display_errors', 1);

// this MUST be called prior to any output including whitespaces and line breaks
session_start();

?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <title>Stream Links</title>
  <link rel="stylesheet" href="securimage.css" media="screen">
  <style type="text/css">
  <!--
  div.error { display: block; color: #f00; font-weight: bold; font-size: 1.2em; }
  span.error { display: block; color: #f00; font-style: italic; }
  .success { color: #00f; font-weight: bold; font-size: 1.2em; }
  form label { display: block; font-weight: bold; }
  fieldset { width: 90%; }
  legend { font-size: 24px; }
  .note { font-size: 18px;
  -->
  </style>
</head>
<body>

<fieldset>
<legend>Stream Links</legend>

<?php

process_si_verify_form(); // Process the form, if it was submitted

if (isset($_SESSION['ctform']['error']) &&  $_SESSION['ctform']['error'] == true): /* The last form submission had 1 or more errors */ ?>
<div class="error">There was a problem with your verification.</div><br>
<?php elseif (isset($_SESSION['ctform']['success']) && $_SESSION['ctform']['success'] == true): /* form was processed successfully */ ?>
<div class="success">The captcha was solved in <?php echo $_SESSION['ctform']['timetosolve'] ?> seconds.</div><br />
<?php endif; ?>

<form method="post" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI'] . $_SERVER['QUERY_STRING']) ?>" id="verify_form">
  <input type="hidden" name="do" value="verifyhumanity">

  <div>
    <?php
      // show captcha HTML using Securimage::getCaptchaHtml()
      require_once 'securimage/securimage.php';
      $options = array();
      $options['input_name']             = 'ct_captcha'; // change name of input element for form post
      $options['disable_flash_fallback'] = false;        // allow flash fallback

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
    <br>
    <input type="submit" value="View stream links">
  </p>

</form>
</fieldset>

</body>
</html>

<?php

// The form processor PHP code
function process_si_verify_form()
{
  $_SESSION['ctform'] = array(); // re-initialize the form session data

  if ($_SERVER['REQUEST_METHOD'] == 'POST' && @$_POST['do'] == 'verifyhumanity') {
    // if the form has been submitted

    // sanitize the input data
    foreach($_POST as $key => $value) {
      if (!is_array($key)) {
        $_POST[$key] = htmlspecialchars(stripslashes(trim($value)));
      }
    }

    $captcha = @$_POST['ct_captcha']; // the user's entry for the captcha code

    $errors = array();  // initialize empty error array

    // You could set some errors here.
    // Only try to validate the captcha if the form has no errors.
    // This is especially important for ajax calls

    // validate captcha
    if (sizeof($errors) == 0) {
      require_once dirname(__FILE__) . '/securimage/securimage.php';
      $securimage = new Securimage();
      if ($securimage->check($captcha) == false) {
        $errors['captcha_error'] = 'Incorrect security code entered<br />';
      }
    }

    if (sizeof($errors) == 0) {
      // no errors and captcha validated, send the form
      $time       = date('r');
      $message = "Validated. The following information was provided.<br /><br />"
                    . "<br /><br /><em>IP Address:</em> {$_SERVER['REMOTE_ADDR']}<br />"
                    . "<em>Time:</em> $time<br />"
                    . "<em>Browser:</em> " . htmlspecialchars($_SERVER['HTTP_USER_AGENT']) . "<br />";

      $_SESSION['ctform']['timetosolve'] = $securimage->getTimeToSolve();
      $_SESSION['ctform']['error'] = false;  // no error with form
      $_SESSION['ctform']['success'] = true; // message sent

    } else {
      // repopulate the form with error messages
      $_SESSION['ctform']['error'] = true; // set error flag
    }
  } // POST
}

$_SESSION['ctform']['success'] = false; // clear success value after running
