module utils

import gololang.concurrent.workers.WorkerEnvironment

let executorService = WorkerEnvironment.builder(): withCachedThreadPool()

function getDefaulExecutorService = -> executorService