<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Validator\Constraints as Assert;

/**
 * @ApiResource(
 *  collectionOperations={"get", "post"={
 *    "denormalization_context"={"groups"={"write"}}
 *  }},
 *  itemOperations={"get", "patch"={
 *    "denormalization_context"={"groups"={"patch"}}
 *  }}
 * )
 * @ORM\Entity(repositoryClass="App\Repository\PresetRepository")
 */
class Preset
{
    /**
     * @ORM\Id()
     * @ORM\GeneratedValue()
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @Groups("write")
     * @Assert\NotBlank
     * @ORM\Column(type="string", length=255)
     */
    private $systemHash;

    /**
     * @Groups("patch")
     * @ORM\Column(type="integer")
     */
    private $upvote = 0;

    /**
     * @Groups("patch")
     * @ORM\Column(type="integer")
     */
    private $downvote = 0;

    /**
     * @Groups("write")
     * @Assert\NotBlank
     * @ORM\Column(type="string", length=255)
     */
    private $name;

    /**
     * @Groups("write")
     * @ORM\Column(type="json")
     */
    private $ryzenAdjArguments = [];

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getSystemHash(): ?string
    {
        return $this->systemHash;
    }

    public function setSystemHash(string $systemHash): self
    {
        $this->systemHash = $systemHash;

        return $this;
    }

    public function getUpvote(): ?int
    {
        return $this->upvote;
    }

    public function setUpvote(int $upvote): self
    {
        $this->upvote = $upvote;

        return $this;
    }

    public function getDownvote(): ?int
    {
        return $this->downvote;
    }

    public function setDownvote(int $downvote): self
    {
        $this->downvote = $downvote;

        return $this;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): self
    {
        $this->name = $name;

        return $this;
    }

    public function getRyzenAdjArguments(): ?array
    {
        return $this->ryzenAdjArguments;
    }

    public function setRyzenAdjArguments(array $ryzenAdjArguments): self
    {
        $this->ryzenAdjArguments = $ryzenAdjArguments;

        return $this;
    }
}
