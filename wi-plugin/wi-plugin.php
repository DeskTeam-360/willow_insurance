<?php
add_action('rest_api_init', function () {
    register_rest_route('custom-api/v1', '/data-init', [
        'methods'  => 'GET',
        'callback' => 'api_data_init',
        'permission_callback' => '__return_true',
    ]);
});

function api_data_init(WP_REST_Request $request) {
    // Get query parameters for logging
    $params = $request->get_query_params();
    $device_id = $params['device_id'] ?? '';
    $event_type = $params['event_type'] ?? 'Open apps';
    
    // Log "open_apps" event when API is called
    log_api_data_init_event([
        'device_id' => $device_id,
        'event_type' => 'Open apps',
        'platform' => $params['platform'] ?? '',
        'device_model' => $params['device_model'] ?? '',
    ]);

    $response = [];

    /* ============================
     * 1. VIDEO GUIDE
     * ============================ */
    $response['video_guide'] = get_post_type_data([
        'post_type' => 'video-guide',
        'fields' => [
            'video',
            'order'
        ]
    ], function($post_id, $fields) {
        return [
            'title'          => get_the_title($post_id),
            'featured_image' => get_the_post_thumbnail_url($post_id, 'full'),
            'video'          => $fields['video'] ?? '',
            'order'          => intval($fields['order'] ?? 0),
        ];
    });


    /* ============================
     * 2. MOBILE SERVICE
     * ============================ */
    $response['mobile_service'] = get_post_type_data([
        'post_type' => 'mobile-service',
        'fields' => [
            'order',
            'link',
            'short_description',
            'group_type',
            'group_layout',
        ]
    ], function($post_id, $fields) {
        return [
            'title'          => get_the_title($post_id),
            'featured_image' => get_the_post_thumbnail_url($post_id, 'full'),
            'order'          => intval($fields['order'] ?? 0),
            'link'           => $fields['link'] ?? '',
            'short_description' => $fields['short_description'] ?? '',
            'group_type'     => $fields['group_type'] ?? '',
            'group_layout'   => $fields['group_layout'] ?? '',
        ];
    });


    /* ============================
     * 3. RESOURCE
     * ============================ */
    $response['resource'] = get_post_type_data([
        'post_type' => 'resource',
        'fields' => [
            'order',
            'link',
            'short_description'
        ]
    ], function($post_id, $fields) {
        return [
            'title'             => get_the_title($post_id),
            'featured_image'    => get_the_post_thumbnail_url($post_id, 'full'),
            'order'             => intval($fields['order'] ?? 0),
            'link'              => $fields['link'] ?? '',
            'short_description' => $fields['short_description'] ?? '',
        ];
    });
	
	/* ============================
     * 3. Book Appointment
     * ============================ */
    $response['book_appointment'] = get_post_type_data([
        'post_type' => 'book-appointment',
        'fields' => [
            'type_of_insurance',
            'appointment_type',
            'agent',
			'location',
			'time_needed',
			'appointment_link'
        ]
    ], function($post_id, $fields) {
        return [
			'type_of_insurance' => $fields['type_of_insurance'] ?? '',
			'appointment_type' => $fields['appointment_type'] ?? '',
			'agent' => $fields['agent'] ?? '',
			'location' => $fields['location'] ?? '',
			'time_needed' => $fields['time_needed'] ?? '',
            'appointment_link' => $fields['appointment_link'] ?? '',	
        ];
    });
	
	/* ============================
     * 4. Notifications
     * ============================ */
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    
    $notifications = $wpdb->get_results(
        "SELECT * FROM `{$table_name}` 
         WHERE status = 'active' 
         AND publish_date <= NOW() 
         AND (end_publish_date IS NULL OR end_publish_date >= NOW())
         ORDER BY publish_date DESC",
        ARRAY_A
    );
    
    // Format notifications
    $response['notifications'] = array_map(function($notification) {
        return [
            'id' => intval($notification['id'] ?? 0),
            'title' => $notification['title'] ?? '',
            'content' => $notification['content'] ?? '',
            'type' => $notification['type'] ?? '',
            'publish_date' => $notification['publish_date'] ?? '',
            'end_publish_date' => $notification['end_publish_date'] ?? null,
            'status' => $notification['status'] ?? '',
            'created_at' => $notification['created_at'] ?? '',
            'updated_at' => $notification['updated_at'] ?? '',
        ];
    }, $notifications ?: []);

    return $response;
}

/**
 * Log API data init events (open apps)
 */
function log_api_data_init_event($event_data) {
    // Use the device location form (ID 5) for logging
    $form_id = 5;
    
    $ip = gf_get_client_ip();
    $ip_loc = gf_ip_to_location($ip);
    
    $entry = array(
        'form_id' => $form_id,
        
        // Identity
        '1' => sanitize_text_field($event_data['device_id'] ?? ''),
        '3' => sanitize_text_field($event_data['event_type'] ?? 'open_apps'),
        '4' => sanitize_text_field($event_data['platform'] ?? ''),
        '5' => sanitize_text_field($event_data['device_model'] ?? ''),
        
        // Location from IP
        '6' => sanitize_text_field($ip_loc['country_code'] ?? ''),
        '7' => sanitize_text_field($ip_loc['region'] ?? ''),
        '8' => sanitize_text_field($ip_loc['city'] ?? ''),
        
        '9'  => $ip_loc['latitude'] ?? '',
        '10' => $ip_loc['longitude'] ?? '',
        
        '11' => sanitize_text_field($ip_loc['location_source'] ?? 'ip'),
        '12' => sanitize_text_field($ip_loc['location_type'] ?? 'coarse'),
        '13' => sanitize_text_field($ip_loc['provider'] ?? 'ipinfo'),
        
        '14' => sanitize_textarea_field('App opened'),
    );
    
    $result = GFAPI::add_entry($entry);
    
    // Optionally log errors
    if (is_wp_error($result)) {
        error_log('Failed to log API data init event: ' . $result->get_error_message());
    }
}

/**
 * Helper: ambil data post_type dengan ACF
 */
function get_post_type_data($config, $formatter) {

    $args = [
        'post_type'      => $config['post_type'],
        'post_status'    => 'publish',
        'posts_per_page' => -1,
        'meta_key'       => 'order',
        'orderby'        => 'meta_value_num',
        'order'          => 'ASC',
    ];

    $query = new WP_Query($args);
    $output = [];

    if ($query->have_posts()) {
        while ($query->have_posts()) {
            $query->the_post();

            $post_id = get_the_ID();
            $fields = [];

            // Ambil ACF fields yang diminta
            foreach ($config['fields'] as $field_name) {
                $fields[$field_name] = get_field($field_name, $post_id);
            }

            // Format via callback
            $output[] = $formatter($post_id, $fields);
        }
    }

    wp_reset_postdata();
    return $output;
}


/*
Plugin Name: Gravity Forms Custom External API
Description: Custom endpoint for submitting Gravity Forms entries from external API.
*/

add_action('rest_api_init', function () {
    register_rest_route('gf-custom/v1', '/submit', array(
        'methods'  => 'POST',
        'callback' => 'gf_custom_submit_entry',
        'permission_callback' => '__return_true', // biar bisa diakses public
    ));
});

function gf_custom_submit_entry(WP_REST_Request $request)
{
    $data = $request->get_json_params();

    if (!$data) {
        return new WP_REST_Response([
            'status'  => 'error',
            'message' => 'Invalid or empty JSON body'
        ], 400);
    }

    // ==============================
    // FORM ID
    // ==============================
    $form_id = 3;

    // ==============================
    // MAPPING KE GRAVITY FORMS FIELD
    // ==============================
    $entry = array(
        'form_id' => $form_id,
        '1' => isset($data['title']) ? sanitize_text_field($data['title']) : '',
        '3' => isset($data['renewal_date']) ? sanitize_text_field($data['renewal_date']) : '',
        '4' => isset($data['notify_me_on']) ? sanitize_text_field($data['notify_me_on']) : '',
        '5' => isset($data['repeat']) ? sanitize_text_field($data['repeat']) : '',
        '6' => isset($data['note']) ? sanitize_text_field($data['note']) : '',
        '8' => isset($data['device_id']) ? sanitize_text_field($data['device_id']) : '',
    );

    // Tambahkan entry ke Gravity Form
    $result = GFAPI::add_entry($entry);

    // Jika gagal
    if (is_wp_error($result)) {
        return new WP_REST_Response([
            'status'  => 'error',
            'message' => $result->get_error_message()
        ], 500);
    }

    // Jika berhasil
    return new WP_REST_Response([
        'status'    => 'success',
        'entry_id'  => $result,
        'message'   => 'Entry created successfully'
    ], 200);
}
// =====================================================
// CUSTOM ENDPOINT � DEVICE LOCATION (FORM ID 5)
// =====================================================

add_action('rest_api_init', function () {
    register_rest_route('gf-custom/v1', '/device-location', array(
        'methods'  => 'POST',
        'callback' => 'gf_custom_device_location_submit',
        'permission_callback' => '__return_true',
    ));
});

function gf_get_client_ip() {
    if (!empty($_SERVER['HTTP_CF_CONNECTING_IP'])) {
        return $_SERVER['HTTP_CF_CONNECTING_IP']; // Cloudflare
    }
    if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        return explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
    }
    return $_SERVER['REMOTE_ADDR'] ?? '';
}

function gf_ip_to_location($ip) {
    if (empty($ip)) return [];

    $token = defined('IPINFO_TOKEN') ? IPINFO_TOKEN : '';
    if (!$token) return [];

    $response = wp_remote_get("https://ipinfo.io/{$ip}?token={$token}", [
        'timeout' => 5,
    ]);

    if (is_wp_error($response)) return [];

    $body = json_decode(wp_remote_retrieve_body($response), true);
    if (!is_array($body)) return [];

    $loc = [];
    if (!empty($body['loc'])) {
        [$lat, $lng] = explode(',', $body['loc']);
        $loc['latitude']  = floatval($lat);
        $loc['longitude'] = floatval($lng);
    }

    return [
        'country_code' => $body['country'] ?? '',
        'region'       => $body['region'] ?? '',
        'city'         => $body['city'] ?? '',
        'latitude'     => $loc['latitude'] ?? null,
        'longitude'    => $loc['longitude'] ?? null,
        'provider'     => 'ipinfo',
        'location_source' => 'ip',
        'location_type'   => 'coarse',
    ];
}


function gf_custom_device_location_submit(WP_REST_Request $request)
{
    $data = $request->get_json_params();

    if (empty($data) || !is_array($data)) {
        return new WP_REST_Response([
            'status'  => 'error',
            'message' => 'Invalid or empty JSON body'
        ], 400);
    }

    if (empty($data['device_id']) || empty($data['event_type'])) {
        return new WP_REST_Response([
            'status'  => 'error',
            'message' => 'device_id and event_type are required'
        ], 422);
    }

    $form_id = 5;

    // ==============================
    // AMBIL LOKASI DARI IP
    // ==============================
    $ip       = gf_get_client_ip();
    $ip_loc   = gf_ip_to_location($ip);

    // ==============================
    // MAPPING KE GRAVITY FORMS
    // ==============================
    $entry = array(
        'form_id' => $form_id,

        // identity
        '1' => sanitize_text_field($data['device_id']),
        '3' => sanitize_text_field($data['event_type']),
        '4' => sanitize_text_field($data['platform'] ?? ''),
        '5' => sanitize_text_field($data['device_model'] ?? ''),

        // location from IP
        '6' => sanitize_text_field($ip_loc['country_code'] ?? ''),
        '7' => sanitize_text_field($ip_loc['region'] ?? ''),
        '8' => sanitize_text_field($ip_loc['city'] ?? ''),

        '9'  => $ip_loc['latitude'] ?? '',
        '10' => $ip_loc['longitude'] ?? '',

        '11' => sanitize_text_field($ip_loc['location_source'] ?? 'ip'),
        '12' => sanitize_text_field($ip_loc['location_type'] ?? 'coarse'),
        '13' => sanitize_text_field($ip_loc['provider'] ?? 'ipinfo'),

        '14' => sanitize_textarea_field($data['note'] ?? ''),
    );

    $result = GFAPI::add_entry($entry);

    if (is_wp_error($result)) {
        return new WP_REST_Response([
            'status'  => 'error',
            'message' => $result->get_error_message()
        ], 500);
    }

    return new WP_REST_Response([
        'status'   => 'success',
        'entry_id' => $result
    ], 200);
}

