<?
require_once ('common.php');
require_once ('carrubbers/rsshandler.php');

display_common_parts ('MEETINGS', 'display_meetings');

function display_meetings() {
	$dl = new m17n;
	$_error = false;
	
	if ( $_GET['year'] ) {
		$_year = $_GET['year'];
	} elseif ( $_POST['year'] ) {
		$_year = $_POST['year'];
	} else {
		$_error = true;
	}
	
	if ( $_GET['month'] ) {
		$_month = $_GET['month'];
	} elseif ( $_POST['month'] ) {
		$_month = $_POST['month'];
	} else {
		$_error = true;
	}
	if (strlen($_month) == 1) {
		$_month = '0' . $_month;
	}
	
	if ($_error) {
		// Displaying the past meeting list
		$dl->getFile('meetings/introduction.html');
		
		$thisyear = date('Y');
		$thismonth = date('m');
		
		while ($thisyear >=2003) {
			while ($thismonth >= 1)
				@_display_meeting ($thisyear, $thismonth);
				$thismonth--;
			}
			$thisyear--;
		}
		
		$dl->getFile('meetings/past.html');
	} else {
		// Displays the meeting page
		$dl->getFile('meetings/introduction.html');
		$dl->getFile('meetings/' . $_year . $_month. '/' . $_year . $_month . '.html');
	}
}

function _display_meeting($year, $month) {
	$tabs = "\t\t\t";
	
	// Initialises to fetch the RSS
	if ($month < 9) $month = '0' . $month;

	$url = "./meetings/$year$month/$year$month.rss";

	if (is_readable ($url)) {
		$rss = new CRssHandler;
		$rss->Open ( $url );
		echo $tabs . "<!-- Displaying $url information -->\n";

		// Displays the information
		$channel = $rss->channel();
		echo $tabs . "<b>" . htmlspecialchars($channel['title']) . "</b><br>\n";
		echo $tabs . "<blockquote>" . htmlspecialchars($channel['description']) . "\n";

		$items = $rss->items();
		for ($i = 0; $i < count($items); $i++ ) {
			$title = $items[$i]['title'];
			echo $tabs . "\t&gt; " . htmlspecialchars($title) . "<br>\n";
		}

		// Adds link to the announcement page
		if ($channel['link'] != '') {
			echo $tabs . "\t[ <a ";
			echo " href=\"" . $channel['link'] . "\"";
			echo " title=\"" . htmlspecialchars($channel['title']) . "\"";
			echo ">more info</a> ]<br><br>\n";
		}
		echo $tabs . "</blockquote>\n";
	}
	return 0;
}
?>
