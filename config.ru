# This file is used by Rack-based servers to start the application.
#require 'unicorn/oob_gc'
#require 'unicorn/worker_killer'

#use Unicorn::OobGC, 20

#use Unicorn::WorkerKiller::MaxRequests, 6144, 7168
#设定达到最大内存后自杀，避免禁止GC带来的内存泄漏（192～256MB之间随机，避免同时多个进程同时自杀）
#use Unicorn::WorkerKiller::Oom, (448*(1024**2)), (512*(1024**2))

require ::File.expand_path('../config/environment',  __FILE__)
run Shangjieba::Application
