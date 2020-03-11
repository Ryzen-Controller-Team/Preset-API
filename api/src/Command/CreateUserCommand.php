<?php

namespace App\Command;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Security\Core\Encoder\UserPasswordEncoderInterface;

class CreateUserCommand extends Command
{
    protected static $defaultName = 'app:create-user';

    /**
     * The password encoder service.
     *
     * @var UserPasswordEncoderInterface
     */
    private $upe;

    /**
     * The entity manager service.
     *
     * @var EntityManagerInterface
     */
    private $em;

    public function __construct(UserPasswordEncoderInterface $upe, EntityManagerInterface $em)
    {
        parent::__construct();
        $this->upe = $upe;
        $this->em = $em;
    }

    protected function configure()
    {
        $this
            // the short description shown while running "php bin/console list"
            ->setDescription('Creates a new user.')

            // the full command description shown when running the command with
            // the "--help" option
            ->setHelp('This command allows you to create a user...')

            ->addArgument('username', InputArgument::REQUIRED, 'Username')
            ->addArgument('email', InputArgument::REQUIRED, 'User email')
            ->addArgument('password', InputArgument::REQUIRED, 'User password')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $user = new User();
        $user
            ->setUsername($input->getArgument('username'))
            ->setEmail($input->getArgument('email'))
            ->setPassword(
                $this->upe->encodePassword(
                    $user,
                    $input->getArgument('password')
                )
            )
        ;

        try {
            $this->em->persist($user);
            $this->em->flush();
            $output->writeln('User created successfully.');
        } catch (\Throwable $th) {
            $output->writeln($th);
        }
        return 0;
    }
}
