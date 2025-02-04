// TODO(jpienaar): Re-enable
// DISABLED: tfg-transforms-opt %s --pass-pipeline="tfg.graph(tfg-toposort), tfg.func(tfg-toposort)" | FileCheck %s

// Sort graphs topologically

// CHECK-LABEL: tfg.graph
tfg.graph #tf_type.version<producer = 42, min_consumer = 33> {
  // CHECK: tfg.placeholder
  // CHECK: tfg.placeholder
  // CHECK: tfg.AddV2
  %arg0, %ctl = "tfg.placeholder"() : () -> (tensor<*xi32>, !tf_type.control)
  %add, %ctl3 = "tfg.AddV2"(%arg0, %arg1) : (tensor<*xi32>, tensor<*xi32>) -> (tensor<*xi32>, !tf_type.control)
  %arg1, %ctl2 = "tfg.placeholder"()  : () -> (tensor<*xi32>, !tf_type.control)
}

// empty graph
// CHECK-LABEL: tfg.graph
tfg.graph #tf_type.version<producer = 1, min_consumer = 1, bad_consumers = [1, 2, 5, 12]> {
}

// This graph has cycles
// CHECK-LABEL: tfg.graph
tfg.graph #tf_type.version<producer = 1, min_consumer = 1, bad_consumers = [1, 2, 5, 12]> {
// CHECK: tfg.placeholder
// CHECK: tfg.placeholder
// CHECK: tfg.AddV2
// CHECK: tfg.fakeNextIteration
  %arg0, %ctl = "tfg.placeholder"() : () -> (tensor<*xi32>, !tf_type.control)
  %add, %ctl1 = "tfg.AddV2"(%arg0, %add_next) : (tensor<*xi32>, tensor<*xi32>) -> (tensor<*xi32>, !tf_type.control)
  %add_next, %ctl2 = "tfg.fakeNextIteration"(%add) : (tensor<*xi32>) -> (tensor<*xi32>, !tf_type.control)
  %arg1, %ctl3 = "tfg.placeholder"()  : () -> (tensor<*xi32>, !tf_type.control)
}

// CHECK-LABEL: tfg.func @foo
tfg.func @foo(%arg0 : tensor<*xf32>, %arg1 : tensor<*xf32>) -> (tensor<*xf32>) {
// CHECK: tfg.Op2
// CHECK: tfg.Op1
// CHECK: tfg.return
  %op1, %ctl1 = "tfg.Op1"(%op2, %arg1) : (tensor<*xf32>, tensor<*xf32>) -> (tensor<*xf32>, !tf_type.control)
  %op2, %ctl2 = "tfg.Op2"(%arg0, %arg1) : (tensor<*xf32>, tensor<*xf32>) -> (tensor<*xf32>, !tf_type.control)
  tfg.return(%op1) : tensor<*xf32>
}
// This graph has cycles
// CHECK-LABEL: tfg.func @cyclic
tfg.func @cyclic() -> (tensor<*xi32>) {
// CHECK: tfg.placeholder
// CHECK: tfg.placeholder
// CHECK: tfg.AddV2
// CHECK: tfg.fakeNextIteration
// CHECK: tfg.return
  %arg0, %ctl = "tfg.placeholder"() : () -> (tensor<*xi32>, !tf_type.control)
  %add, %ctl1 = "tfg.AddV2"(%arg0, %add_next) : (tensor<*xi32>, tensor<*xi32>) -> (tensor<*xi32>, !tf_type.control)
  %add_next, %ctl2 = "tfg.fakeNextIteration"(%add) : (tensor<*xi32>) -> (tensor<*xi32>, !tf_type.control)
  %arg1, %ctl3 = "tfg.placeholder"()  : () -> (tensor<*xi32>, !tf_type.control)
  tfg.return(%arg0) : tensor<*xi32>
}

