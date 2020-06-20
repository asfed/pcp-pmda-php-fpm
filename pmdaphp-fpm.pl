#
# Copyright (c) 2015 Red Hat.
# Copyright (c) 2013 Ryan Doyle.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
# 

use strict;
use warnings;
use PCP::PMDA;
use LWP::UserAgent;

my @php_fpm_status = ();
my $php_fpm_status_url = "http://localhost/status";
my $php_fpm_status_available = 0;
my $php_fpm_fetch_timeout = 1;
my $http_client = LWP::UserAgent->new;

# Configuration files for overriding the above settings
for my $file (pmda_config('PCP_PMDAS_DIR') . '/nginx/nginx.conf', 'nginx.conf') {
	eval `cat $file` unless ! -f $file;
}

$http_client->agent('pmdaphp_fpm');
$http_client->timeout($php_fpm_fetch_timeout);

sub update_php_fpm_status 
{
	my $response = $http_client->get($php_fpm_status_url);
	if ($response->is_success) {
	    # All the content on the status page are digits. Map the array
	    # index to the metric item ID.
	    @php_fpm_status = ($response->decoded_content =~ m/:[ ]+(.*)/gm);
	    $php_fpm_status_available = 1;
	} else {
	    @php_fpm_status = undef;
	    $php_fpm_status_available = 0;
	}
}

sub php_fpm_fetch_callback
{
	my ($cluster, $item, $inst) = @_;
	unless ($php_fpm_status_available == 1) {
	    return (PM_ERR_AGAIN, 0);
	}
	unless ($cluster == 0 && defined($php_fpm_status[$item])) {
	    return (PM_ERR_PMID, 0);
	}
	return ($php_fpm_status[$item], 1);
}

my $pmda = PCP::PMDA->new('php_fpm', 200);

$pmda->add_metric(pmda_pmid(0,0), PM_TYPE_STRING, PM_INDOM_NULL,
	PM_SEM_INSTANT, pmda_units(0,0,0,0,0,0),
	'php_fpm.pool',
	'Pool', '');
$pmda->add_metric(pmda_pmid(0,1), PM_TYPE_STRING, PM_INDOM_NULL,
	PM_SEM_INSTANT, pmda_units(0,0,0,0,0,0),
	'php_fpm.process_manage',
	'Process manager', '');
$pmda->add_metric(pmda_pmid(0,2), PM_TYPE_STRING, PM_INDOM_NULL,
	PM_SEM_INSTANT, pmda_units(0,0,0,0,0,0),
	'php_fpm.start_time',
	'Start time', '');
$pmda->add_metric(pmda_pmid(0,3), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,1,0,0,PM_COUNT_ONE),
	'php_fpm.start_since',
	'Start since', '');
$pmda->add_metric(pmda_pmid(0,4), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_INSTANT, pmda_units(0,0,0,0,0,0),
	'php_fpm.accepted_con',
	'Accepted con', '');
$pmda->add_metric(pmda_pmid(0,5), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_INSTANT, pmda_units(0,0,0,0,0,0),
	'php_fpm.listen_queue',
	'Listen queue', '');
$pmda->add_metric(pmda_pmid(0,6), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.max_listen_queue',
	'Max listen queue', '');
$pmda->add_metric(pmda_pmid(0,7), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.listen_queue_len',
	'Listen queue len', '');
$pmda->add_metric(pmda_pmid(0,8), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.idle_processes',
	'Idle processes', '');
$pmda->add_metric(pmda_pmid(0,9), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.active_processes',
	'Active processes', '');
$pmda->add_metric(pmda_pmid(0,10), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.total_processes',
	'Total processes', '');
$pmda->add_metric(pmda_pmid(0,11), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.max_active_processes',
	'Max active processes', '');
$pmda->add_metric(pmda_pmid(0,12), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.max_children_reached',
	'Max children reached', '');
$pmda->add_metric(pmda_pmid(0,13), PM_TYPE_U32, PM_INDOM_NULL,
	PM_SEM_COUNTER, pmda_units(0,0,0,0,0,0),
	'php_fpm.slow_requests',
	'Slow requests', '');

$pmda->set_fetch_callback(\&php_fpm_fetch_callback);
$pmda->set_refresh(\&update_php_fpm_status);
$pmda->set_user('pcp');
$pmda->run;
