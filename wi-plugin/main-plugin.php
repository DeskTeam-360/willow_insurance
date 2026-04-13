<?php
/**
 * Plugin Name: Willow Insurance - Notification Manager
 * Description: Admin interface to manage notifications
 * Version: 1.0.0
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Create database table on plugin activation
register_activation_hook(__FILE__, 'wi_create_notification_table');

function wi_create_notification_table() {
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    $charset_collate = $wpdb->get_charset_collate();
    
    $sql = "CREATE TABLE IF NOT EXISTS `{$table_name}` (
        `id` bigint(20) NOT NULL AUTO_INCREMENT,
        `title` varchar(255) NOT NULL,
        `content` text NOT NULL,
        `type` varchar(100) DEFAULT '',
        `publish_date` datetime NOT NULL,
        `end_publish_date` datetime DEFAULT NULL,
        `status` enum('draft','active','stop') NOT NULL DEFAULT 'draft',
        `created_at` datetime NOT NULL,
        `updated_at` datetime NOT NULL,
        PRIMARY KEY (`id`),
        KEY `status` (`status`),
        KEY `publish_date` (`publish_date`)
    ) {$charset_collate};";
    
    require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
    dbDelta($sql);
}

// Check and create table if not exists (for manual activation)
add_action('admin_init', 'wi_check_notification_table');

function wi_check_notification_table() {
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    
    if ($wpdb->get_var("SHOW TABLES LIKE '{$table_name}'") != $table_name) {
        wi_create_notification_table();
    }
}

// Add admin menu
add_action('admin_menu', 'wi_notification_admin_menu');

function wi_notification_admin_menu() {
    add_menu_page(
        'Notification Manager',
        'Notifications',
        'manage_options',
        'wi-notifications',
        'wi_notification_admin_page',
        'dashicons-bell',
        30
    );
}

// Enqueue admin styles and scripts
add_action('admin_enqueue_scripts', 'wi_notification_admin_assets');

function wi_notification_admin_assets($hook) {
    if (strpos($hook, 'wi-notifications') === false) {
        return;
    }
    
    wp_enqueue_style('wp-color-picker');
    wp_enqueue_script('wp-color-picker');
    wp_enqueue_script('jquery-ui-datepicker');
    wp_enqueue_style('jquery-ui-css', 'https://code.jquery.com/ui/1.12.1/themes/ui-lightness/jquery-ui.css');
}

// Handle form submissions
add_action('admin_post_wi_save_notification', 'wi_handle_save_notification');
add_action('admin_post_wi_delete_notification', 'wi_handle_delete_notification');

function wi_handle_save_notification() {
    // Check nonce
    if (!isset($_POST['wi_notification_nonce']) || !wp_verify_nonce($_POST['wi_notification_nonce'], 'wi_save_notification')) {
        wp_die('Security check failed');
    }
    
    // Check permissions
    if (!current_user_can('manage_options')) {
        wp_die('You do not have permission to perform this action');
    }
    
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    
    $id = isset($_POST['notification_id']) ? intval($_POST['notification_id']) : 0;
    $title = sanitize_text_field($_POST['title'] ?? '');
    $content = sanitize_textarea_field($_POST['content'] ?? '');
    $type = sanitize_text_field($_POST['type'] ?? '');
    $status = sanitize_text_field($_POST['status'] ?? 'draft');
    $publish_date = sanitize_text_field($_POST['publish_date'] ?? '');
    $end_publish_date = !empty($_POST['end_publish_date']) ? sanitize_text_field($_POST['end_publish_date']) : null;
    
    // Validate required fields
    if (empty($title) || empty($content) || empty($publish_date)) {
        wp_redirect(add_query_arg(['page' => 'wi-notifications', 'action' => 'edit', 'id' => $id, 'error' => 'missing_fields'], admin_url('admin.php')));
        exit;
    }
    
    $data = [
        'title' => $title,
        'content' => $content,
        'type' => $type,
        'status' => $status,
        'publish_date' => $publish_date,
        'end_publish_date' => $end_publish_date,
        'updated_at' => current_time('mysql'),
    ];
    
    if ($id > 0) {
        // Update existing
        $wpdb->update($table_name, $data, ['id' => $id]);
        $message = 'updated';
    } else {
        // Insert new
        $data['created_at'] = current_time('mysql');
        $wpdb->insert($table_name, $data);
        $message = 'created';
    }
    
    wp_redirect(add_query_arg(['page' => 'wi-notifications', 'message' => $message], admin_url('admin.php')));
    exit;
}

function wi_handle_delete_notification() {
    // Check nonce
    if (!isset($_GET['nonce']) || !wp_verify_nonce($_GET['nonce'], 'wi_delete_notification_' . $_GET['id'])) {
        wp_die('Security check failed');
    }
    
    // Check permissions
    if (!current_user_can('manage_options')) {
        wp_die('You do not have permission to perform this action');
    }
    
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    $id = intval($_GET['id'] ?? 0);
    
    if ($id > 0) {
        $wpdb->delete($table_name, ['id' => $id]);
    }
    
    wp_redirect(add_query_arg(['page' => 'wi-notifications', 'message' => 'deleted'], admin_url('admin.php')));
    exit;
}

// Main admin page
function wi_notification_admin_page() {
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    
    $action = $_GET['action'] ?? 'list';
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    // Show messages
    if (isset($_GET['message'])) {
        $messages = [
            'created' => '<div class="notice notice-success is-dismissible"><p>Notification created successfully!</p></div>',
            'updated' => '<div class="notice notice-success is-dismissible"><p>Notification updated successfully!</p></div>',
            'deleted' => '<div class="notice notice-success is-dismissible"><p>Notification deleted successfully!</p></div>',
        ];
        echo $messages[$_GET['message']] ?? '';
    }
    
    if (isset($_GET['error'])) {
        echo '<div class="notice notice-error is-dismissible"><p>Error: ' . esc_html($_GET['error']) . '</p></div>';
    }
    
    if ($action === 'edit' || $action === 'add') {
        wi_render_notification_form($id);
    } else {
        wi_render_notification_list();
    }
}

// Render notification list
function wi_render_notification_list() {
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    
    // Get all notifications
    $notifications = $wpdb->get_results(
        "SELECT * FROM `{$table_name}` ORDER BY publish_date DESC, created_at DESC",
        ARRAY_A
    );
    
    ?>
    <div class="wrap">
        <h1 class="wp-heading-inline">Notification Manager</h1>
        <a href="<?php echo admin_url('admin.php?page=wi-notifications&action=add'); ?>" class="page-title-action">Add New</a>
        <hr class="wp-header-end">
        
        <table class="wp-list-table widefat fixed striped">
            <thead>
                <tr>
                    <th style="width: 5%;">ID</th>
                    <th style="width: 20%;">Title</th>
                    <th style="width: 15%;">Type</th>
                    <th style="width: 10%;">Status</th>
                    <th style="width: 15%;">Publish Date</th>
                    <th style="width: 15%;">End Date</th>
                    <th style="width: 20%;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($notifications)): ?>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 20px;">
                            <p>No notifications found. <a href="<?php echo admin_url('admin.php?page=wi-notifications&action=add'); ?>">Create your first notification</a></p>
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($notifications as $notification): ?>
                        <tr>
                            <td><?php echo esc_html($notification['id']); ?></td>
                            <td><strong><?php echo esc_html($notification['title']); ?></strong></td>
                            <td><?php echo esc_html($notification['type']); ?></td>
                            <td>
                                <span class="status-badge status-<?php echo esc_attr($notification['status']); ?>">
                                    <?php echo esc_html(ucfirst($notification['status'])); ?>
                                </span>
                            </td>
                            <td><?php echo esc_html($notification['publish_date']); ?></td>
                            <td><?php echo $notification['end_publish_date'] ? esc_html($notification['end_publish_date']) : '<em>No end date</em>'; ?></td>
                            <td>
                                <a href="<?php echo admin_url('admin.php?page=wi-notifications&action=edit&id=' . $notification['id']); ?>" class="button button-small">Edit</a>
                                <a href="<?php echo wp_nonce_url(admin_url('admin-post.php?action=wi_delete_notification&id=' . $notification['id']), 'wi_delete_notification_' . $notification['id']); ?>" 
                                   class="button button-small button-link-delete" 
                                   onclick="return confirm('Are you sure you want to delete this notification?');">Delete</a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
    
    <style>
        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-active {
            background: #00a32a;
            color: #fff;
        }
        .status-draft {
            background: #dba617;
            color: #fff;
        }
        .status-stop {
            background: #d63638;
            color: #fff;
        }
    </style>
    <?php
}

// Render notification form
function wi_render_notification_form($id = 0) {
    global $wpdb;
    $table_name = $wpdb->prefix . 'apps_notifications';
    
    $notification = null;
    if ($id > 0) {
        $notification = $wpdb->get_row($wpdb->prepare("SELECT * FROM `{$table_name}` WHERE id = %d", $id), ARRAY_A);
        if (!$notification) {
            echo '<div class="notice notice-error"><p>Notification not found.</p></div>';
            return;
        }
    }
    
    $title = $notification['title'] ?? '';
    $content = $notification['content'] ?? '';
    $type = $notification['type'] ?? '';
    $status = $notification['status'] ?? 'draft';
    $publish_date = $notification['publish_date'] ?? '';
    $end_publish_date = $notification['end_publish_date'] ?? '';
    
    ?>
    <div class="wrap">
        <h1><?php echo $id > 0 ? 'Edit Notification' : 'Add New Notification'; ?></h1>
        <a href="<?php echo admin_url('admin.php?page=wi-notifications'); ?>" class="page-title-action">← Back to List</a>
        
        <form method="post" action="<?php echo admin_url('admin-post.php'); ?>" id="wi-notification-form">
            <?php wp_nonce_field('wi_save_notification', 'wi_notification_nonce'); ?>
            <input type="hidden" name="action" value="wi_save_notification">
            <input type="hidden" name="notification_id" value="<?php echo esc_attr($id); ?>">
            
            <table class="form-table">
                <tr>
                    <th scope="row">
                        <label for="title">Title <span class="required">*</span></label>
                    </th>
                    <td>
                        <input type="text" 
                               id="title" 
                               name="title" 
                               value="<?php echo esc_attr($title); ?>" 
                               class="regular-text" 
                               required>
                        <p class="description">Notification title to be displayed</p>
                    </td>
                </tr>
                
                <tr>
                    <th scope="row">
                        <label for="content">Content <span class="required">*</span></label>
                    </th>
                    <td>
                        <?php
                        wp_editor($content, 'content', [
                            'textarea_name' => 'content',
                            'textarea_rows' => 10,
                            'media_buttons' => false,
                            'teeny' => true,
                        ]);
                        ?>
                        <p class="description">Notification content</p>
                    </td>
                </tr>
                
                <tr>
                    <th scope="row">
                        <label for="type">Type</label>
                    </th>
                    <td>
                        <input type="text" 
                               id="type" 
                               name="type" 
                               value="<?php echo esc_attr($type); ?>" 
                               class="regular-text"
                               placeholder="e.g., info, warning, success">
                        <p class="description">Notification type (optional)</p>
                    </td>
                </tr>
                
                <tr>
                    <th scope="row">
                        <label for="status">Status <span class="required">*</span></label>
                    </th>
                    <td>
                        <select id="status" name="status" required>
                            <option value="draft" <?php selected($status, 'draft'); ?>>Draft</option>
                            <option value="active" <?php selected($status, 'active'); ?>>Active</option>
                            <option value="stop" <?php selected($status, 'stop'); ?>>Stop</option>
                        </select>
                        <p class="description">Notification status</p>
                    </td>
                </tr>
                
                <tr>
                    <th scope="row">
                        <label for="publish_date">Publish Date <span class="required">*</span></label>
                    </th>
                    <td>
                        <input type="datetime-local" 
                               id="publish_date" 
                               name="publish_date" 
                               value="<?php echo esc_attr($publish_date ? date('Y-m-d\TH:i', strtotime($publish_date)) : ''); ?>" 
                               class="regular-text" 
                               required>
                        <p class="description">Date and time when notification starts displaying</p>
                    </td>
                </tr>
                
                <tr>
                    <th scope="row">
                        <label for="end_publish_date">End Publish Date</label>
                    </th>
                    <td>
                        <input type="datetime-local" 
                               id="end_publish_date" 
                               name="end_publish_date" 
                               value="<?php echo esc_attr($end_publish_date ? date('Y-m-d\TH:i', strtotime($end_publish_date)) : ''); ?>" 
                               class="regular-text">
                        <p class="description">End date and time for notification (optional, leave empty if no end date)</p>
                    </td>
                </tr>
            </table>
            
            <p class="submit">
                <input type="submit" name="submit" id="submit" class="button button-primary" value="<?php echo $id > 0 ? 'Update Notification' : 'Create Notification'; ?>">
                <a href="<?php echo admin_url('admin.php?page=wi-notifications'); ?>" class="button">Cancel</a>
            </p>
        </form>
    </div>
    
    <style>
        .required {
            color: #d63638;
        }
        #wi-notification-form .form-table th {
            width: 200px;
        }
        #wi-notification-form .form-table td {
            padding: 15px 10px;
        }
    </style>
    
    <script>
    jQuery(document).ready(function($) {
        // Set default publish_date to now if empty
        if (!$('#publish_date').val()) {
            var now = new Date();
            now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
            $('#publish_date').val(now.toISOString().slice(0, 16));
        }
    });
    </script>
    <?php
}
