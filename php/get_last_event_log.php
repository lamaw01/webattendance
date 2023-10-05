<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// if not put device_id die
if($_SERVER['REQUEST_METHOD'] == 'GET'){
    
    $sql = "SELECT tbl_event_log.id, tbl_event_log.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name, tbl_event_log.event_id, tbl_event.event_name, tbl_event_log.time_stamp 
    FROM tbl_event_log INNER JOIN tbl_employee ON tbl_employee.employee_id = tbl_event_log.employee_id INNER JOIN tbl_event ON tbl_event.event_id = tbl_event_log.event_id
    WHERE tbl_event_log.event_id = (SELECT event_id FROM tbl_event WHERE event_id=(SELECT MAX(event_id) FROM tbl_event)) ORDER BY tbl_event_log.time_stamp DESC;";

    try {
        $get_sql= $conn->prepare($sql);
        $get_sql->execute();
        $result_get_sql = $get_sql->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($result_get_sql);
    } catch (PDOException $e) {
        echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
    } finally{
        // Closing the connection.
        $conn = null;
    }
}else{
    echo json_encode(array('success'=>false,'message'=>'error input'));
    die();
}
?>