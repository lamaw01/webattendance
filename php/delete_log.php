<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);


if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('id', $input)){
    $id = $input['id'];
    $employee_id = $input['employee_id'];

    $sql = 'DELETE FROM tbl_event_log WHERE id=:id AND employee_id=:employee_id'; 

    try {
        $sql_delete = $conn->prepare($sql);
        $sql_delete->bindParam(':id', $id, PDO::PARAM_INT);
        $sql_delete->bindParam(':employee_id', $employee_id, PDO::PARAM_STR);
        $sql_delete->execute();
        echo json_encode(array('success'=>true,'message'=>'ok'));
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