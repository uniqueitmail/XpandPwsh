﻿using System.Management.Automation;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Threading.Tasks;
using JetBrains.Annotations;
using XpandPwsh.CmdLets;

namespace XpandPwsh.Cmdlets.GitHub.GetGitHubLabel{
    [CmdletBinding]
    [Cmdlet(VerbsCommon.Get, "GitHubLabel")]
    [CmdLetTag(CmdLetTag.GitHub,CmdLetTag.Reactive,CmdLetTag.RX)][PublicAPI]
    public class GetGitHubLabel : GitHubCmdlet{
        [Parameter(Mandatory = true)]
        public string Repository{ get; set; }
        
        protected override Task ProcessRecordAsync(){
            return GitHubClient.Repository.GetForOrg(Organization, Repository)
                .SelectMany(repository => GitHubClient.Issue.Labels.GetAllForRepository(repository.Id).ToObservable()
                    .SelectMany(list => list))
                .WriteObject(this)
                .ToTask();
        }
    }
}