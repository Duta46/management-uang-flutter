<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\RecurringExpenseService;

class ProcessRecurringExpenses extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:process-recurring-expenses';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Process recurring expenses that are due';

    /**
     * Execute the console command.
     */
    public function handle(RecurringExpenseService $recurringExpenseService)
    {
        $this->info('Processing recurring expenses...');

        $recurringExpenseService->processRecurringExpenses();

        $this->info('Recurring expenses processed successfully.');
    }
}
