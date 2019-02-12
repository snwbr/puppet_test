$workdir = "/var/save/puppet_move_3"
$folders = ["${workdir}/files",
			"${workdir}/files/text",
			"${workdir}/files/script",
			"${workdir}/files/code"]
$command = "/bin/mv"

define common {
	$folders.each |String $folder| {
		file {"Ensuring folder exists - ${folder}":
			ensure => directory,
			path => "${folder}",
		}
	}
}

define move {
	exec {"Moving text files":
		command => "${command} old/*.txt files/text/",
		cwd => "${workdir}",
	} ->
	exec {"Moving script files":
		command => "${command} old/*.pp old/*.py old/*.sh files/script/",
		cwd => "${workdir}",
	} ->
	exec {"Moving code files":
		command => "${command} old/*.c old/*.cs old/*.cpp old/*.java files/code/",
		cwd => "${workdir}",
	} ->
	file {"Moving other files":
		ensure => directory,
		path => "${workdir}/files/other/",
		source => "file://${workdir}/old/",
		recurse => true,
		force => true,
		ignore => ["*.txt","*.pp","*.py","*.sh","*.c","*.cpp","*.cs","*.java"],
	} ->
	tidy {"Purging other files":
		path => "${workdir}/old/",
		recurse => true,
	}
}

common { "Managing folders" : } ->
move { "Moving files" : }
